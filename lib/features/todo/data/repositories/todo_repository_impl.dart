import 'package:dartz/dartz.dart' hide Task;
import 'package:todo_assignment/core/database/database_helper.dart';
import 'package:todo_assignment/core/network/network_info.dart';
import 'package:todo_assignment/core/error/failures.dart';
import '../../domain/entities/task.dart';
import '../../domain/repositories/todo_repository.dart';
import '../models/task_model.dart';
import '../datasources/todo_remote_datasource.dart';

class TodoRepositoryImpl implements TodoRepository {
  final TodoRemoteDataSource remoteDataSource;
  final DatabaseHelper database;
  final NetworkInfo networkInfo;

  TodoRepositoryImpl({
    required this.remoteDataSource,
    required this.database,
    required this.networkInfo,
  });

  Future<void> _syncPendingTasks() async {
    final pendingTasks = await database.getPendingSyncTasks();
    if (pendingTasks.isEmpty) return;

    for (final task in pendingTasks) {
      if (task.isDeleted) {
        if (task.id != -1) {
          final result = await remoteDataSource.deleteTask(task.id);
          await result.fold((failure) async => null, (response) async {
            await database.hardDeleteTask(localId: task.localId);
          });
        } else {
          await database.hardDeleteTask(localId: task.localId);
        }
        continue;
      }

      if (task.id == -1) {
        final result = await remoteDataSource.addTask(task.toJson());
        await result.fold((failure) async => null, (response) async {
          final remoteTask = TaskModel.fromJson(response.data);
          final newId = remoteTask.id;

          if (newId != -1) {
            // Check if a task with this server ID already exists locally
            final existingTask = await database.getTaskByServerId(newId);
            if (existingTask != null) {
              // If it exists, update the existing one and delete the current temporary one
              await database.updateTaskLocal(
                remoteTask.copyWith(
                  localId: existingTask.localId,
                  isLocalEdit: false,
                ),
              );
              await database.hardDeleteTask(localId: task.localId);
            } else {
              // Otherwise, update the current temporary task with the new server ID
              final syncedTask = task.copyWith(id: newId, isLocalEdit: false);
              await database.updateTaskLocal(syncedTask);
            }
          }
        });
      } else {
        final result = await remoteDataSource.updateTask(
          task.id,
          task.toJson(),
        );
        await result.fold((failure) async => null, (response) async {
          final syncedTask = task.copyWith(isLocalEdit: false);
          await database.updateTaskLocal(syncedTask);
        });
      }
    }
  }

  @override
  Future<Either<Failure, List<Task>>> getTasks({String? query}) async {
    if (await networkInfo.isConnected) {
      await _syncPendingTasks();

      final result = await remoteDataSource.getTasks(query: query);

      return result.fold(
        (failure) async {
          final localTasks = await database.getAllTasks(query: query);
          return Right(localTasks);
        },
        (response) async {
          final List<dynamic> data = response.data;
          final remoteTasks = TaskModel.fromJsonList(data);

          if (query == null || query.isEmpty) {
            await database.upsertSyncedTasks(remoteTasks);
          }

          // remote tasks updated locally
          // local tasks are combination of remote tasks and locally added tasks that are not synced yet.
          final localTasks = await database.getAllTasks(query: query);
          return Right(localTasks);
        },
      );
    }

    final localTasks = await database.getAllTasks(query: query);
    return Right(localTasks);
  }

  @override
  Future<Either<Failure, void>> addTask(Task task) async {
    final taskModel = TaskModel.fromEntity(task, isLocalEdit: true);

    if (await networkInfo.isConnected) {
      final result = await remoteDataSource.addTask(taskModel.toJson());

      return result.fold(
        (failure) async {
          await database.insertTask(taskModel);
          return const Left(
            NetworkFailure('Task added locally. Refresh to sync.'),
          );
        },
        (response) async {
          final remoteTask = TaskModel.fromJson(response.data);
          final newId = remoteTask.id;

          if (newId != -1) {
            // Check if a task with this server ID already exists locally
            final existingTask = await database.getTaskByServerId(newId);
            if (existingTask != null) {
              // If it exists, update it instead of inserting a new one
              await database.updateTaskLocal(
                remoteTask.copyWith(
                  localId: existingTask.localId,
                  isLocalEdit: false,
                ),
              );
              return const Right(null);
            }
          }

          await database.insertTask(
            remoteTask.copyWith(isLocalEdit: newId == -1),
          );
          return const Right(null);
        },
      );
    }

    await database.insertTask(taskModel);
    return const Left(NetworkFailure('Task added locally. Refresh to sync.'));
  }

  @override
  Future<Either<Failure, void>> updateTask(Task task) async {
    TaskModel taskModel;
    if (task is TaskModel) {
      taskModel = task.copyWith(isLocalEdit: true);
    } else {
      taskModel = TaskModel.fromEntity(task, isLocalEdit: true);
    }

    if (await networkInfo.isConnected && task.id != -1) {
      final result = await remoteDataSource.updateTask(
        task.id,
        taskModel.toJson(),
      );

      return result.fold(
        (failure) async {
          await database.updateTaskLocal(taskModel);
          return const Left(
            NetworkFailure('Task updated locally. Refresh to sync.'),
          );
        },
        (response) async {
          final syncedTask = taskModel.copyWith(isLocalEdit: false);
          await database.updateTaskLocal(syncedTask);
          return const Right(null);
        },
      );
    }

    await database.updateTaskLocal(taskModel);
    return const Left(NetworkFailure('Task updated locally. Refresh to sync.'));
  }

  @override
  Future<Either<Failure, void>> deleteTask({
    required int id,
    required int localId,
  }) async {
    if (await networkInfo.isConnected && id != -1) {
      final result = await remoteDataSource.deleteTask(id);

      return result.fold(
        (failure) async {
          await database.deleteTaskLocal(id: id, localId: localId);
          return const Left(
            NetworkFailure('Task deleted locally. Refresh to sync.'),
          );
        },
        (response) async {
          await database.deleteTaskLocal(id: id, localId: localId);
          return const Right(null);
        },
      );
    }

    await database.deleteTaskLocal(id: id, localId: localId);
    return const Left(NetworkFailure('Task deleted locally. Refresh to sync.'));
  }
}
