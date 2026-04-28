import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:todo_assignment/core/constants/app_constant.dart';
import '../../features/todo/data/models/task_model.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(join(dbFolder.path, 'todo_app.db'));

    debugPrint('--- [SQLite] Initializing Database at: ${file.path} ---');

    final db = sqlite3.open(file.path);

    db.execute('''
      CREATE TABLE IF NOT EXISTS tasks (
        localId INTEGER PRIMARY KEY AUTOINCREMENT,
        id INTEGER DEFAULT -1,
        title TEXT,
        isCompleted INTEGER,
        isLocalEdit INTEGER DEFAULT 0,
        isDeleted INTEGER DEFAULT 0
      )
    ''');

    return db;
  }

  void _logQuery(String sql, [List<Object?>? params]) {
    debugPrint('--- [SQLite] Executing Query: $sql ---');
    if (params != null && params.isNotEmpty) {
      debugPrint('--- [SQLite] Parameters: $params ---');
    }
  }

  // Task operations
  Future<List<TaskModel>> getAllTasks({String? query}) async {
    final db = await database;
    final String sql;
    final List<Object?> params;

    if (query != null && query.isNotEmpty) {
      sql =
          'SELECT * FROM tasks WHERE isDeleted = 0 AND title LIKE ? ORDER BY localId DESC';
      params = ['%$query%'];
    } else {
      sql = 'SELECT * FROM tasks WHERE isDeleted = 0 ORDER BY localId DESC';
      params = [];
    }

    _logQuery(sql, params);
    final results = db.select(sql, params);
    return results.map((row) => TaskModel.fromMap(row)).toList();
  }

  Future<List<TaskModel>> getPendingSyncTasks() async {
    final db = await database;
    const sql = 'SELECT * FROM tasks WHERE isLocalEdit = 1 OR isDeleted = 1';
    _logQuery(sql);
    final results = db.select(sql);
    return results.map((row) => TaskModel.fromMap(row)).toList();
  }

  Future<TaskModel?> getTaskByServerId(int id) async {
    // When duplicate server IDs are allowed, callers should not collapse
    // multiple created tasks into a single local record.
    if(allowDuplicateServerIds) return null;
    final db = await database;
    const sql = 'SELECT * FROM tasks WHERE id = ? LIMIT 1';
    final params = [id];
    _logQuery(sql, params);
    final results = db.select(sql, params);

    if (results.isEmpty) return null;
    return TaskModel.fromMap(results.first);
  }

  Future<void> insertTask(TaskModel task) async {
    final db = await database;
    const sql = '''
      INSERT INTO tasks (id, title, isCompleted, isLocalEdit, isDeleted)
      VALUES (?, ?, ?, ?, ?)
    ''';
    final params = [
      task.id,
      task.title,
      task.isCompleted ? 1 : 0,
      task.isLocalEdit ? 1 : 0,
      task.isDeleted ? 1 : 0,
    ];
    _logQuery(sql, params);
    db.execute(sql, params);
  }

  Future<void> updateTaskLocal(TaskModel task) async {
    final db = await database;
    const sql = '''
      UPDATE tasks 
      SET id = ?, title = ?, isCompleted = ?, isLocalEdit = ?, isDeleted = ?
      WHERE localId = ?
    ''';
    final params = [
      task.id,
      task.title,
      task.isCompleted ? 1 : 0,
      task.isLocalEdit ? 1 : 0,
      task.isDeleted ? 1 : 0,
      task.localId,
    ];
    _logQuery(sql, params);
    db.execute(sql, params);
  }

  /// Bulk update synced records with optimization:
  /// 1. Fetches all existing record IDs in a single query.
  /// 2. Executes all updates/inserts within a single transaction.
  Future<void> upsertSyncedTasks(List<TaskModel> tasks) async {
    if (tasks.isEmpty) return;
    final db = await database;

    // 1. Fetch all existing records that match the server IDs
    final serverIds = tasks.where((t) => t.id != -1).map((t) => t.id).toList();
    if (serverIds.isEmpty) return;

    final placeholders = List.filled(serverIds.length, '?').join(',');
    final checkSql =
        'SELECT localId, id, isLocalEdit FROM tasks WHERE id IN ($placeholders)';

    _logQuery(checkSql, serverIds);
    final results = db.select(checkSql, serverIds);

    // Map serverId -> {localId, isLocalEdit}
    final existingMap = {
      for (final row in results)
        row['id'] as int: {
          'localId': row['localId'] as int,
          'isLocalEdit': row['isLocalEdit'] as int == 1,
        },
    };

    // 2. Execute all changes within a transaction
    db.execute('BEGIN');
    try {
      for (final task in tasks) {
        if (task.id == -1) continue;

        final existing = existingMap[task.id];

        if (existing != null) {
          final int localId = existing['localId'] as int;
          // final bool isLocalEdit = existing['isLocalEdit'] as bool;

          // if (!isLocalEdit) {
          const sql = '''
              UPDATE tasks 
              SET title = ?, isCompleted = ?, isDeleted = ?, isLocalEdit = 0 
              WHERE localId = ?
            ''';
          final params = [
            task.title,
            task.isCompleted ? 1 : 0,
            task.isDeleted ? 1 : 0,
            localId,
          ];
          db.execute(sql, params);
          // }
        } else {
          const sql = '''
            INSERT INTO tasks (id, title, isCompleted, isLocalEdit, isDeleted)
            VALUES (?, ?, ?, 0, 0)
          ''';
          final params = [task.id, task.title, task.isCompleted ? 1 : 0];
          db.execute(sql, params);
        }
      }
      db.execute('COMMIT');
      debugPrint('--- [SQLite] Bulk upsert completed successfully ---');
    } catch (e) {
      // db.execute('ROLLBACK');
      debugPrint('--- [SQLite] Bulk upsert failed, rolled back: $e ---');
      rethrow;
    }
  }

  Future<void> deleteSyncedTasks() async {
    final db = await database;
    const sql = 'DELETE FROM tasks WHERE isLocalEdit = 0 AND isDeleted = 0';
    _logQuery(sql);
    db.execute(sql);
  }

  Future<void> deleteTaskLocal({int id = -1, int localId = 0}) async {
    final db = await database;
    if (localId != 0) {
      const sql = 'UPDATE tasks SET isDeleted = 1 WHERE localId = ?';
      _logQuery(sql, [localId]);
      db.execute(sql, [localId]);
    } else if (id != -1) {
      const sql = 'UPDATE tasks SET isDeleted = 1 WHERE id = ?';
      _logQuery(sql, [id]);
      db.execute(sql, [id]);
    }
  }

  Future<void> hardDeleteTask({int id = -1, int localId = 0}) async {
    final db = await database;
    if (localId != 0) {
      const sql = 'DELETE FROM tasks WHERE localId = ?';
      _logQuery(sql, [localId]);
      db.execute(sql, [localId]);
    } else if (id != -1) {
      const sql = 'DELETE FROM tasks WHERE id = ?';
      _logQuery(sql, [id]);
      db.execute(sql, [id]);
    }
  }
}
