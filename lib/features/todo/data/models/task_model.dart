import '../../domain/entities/task.dart';

class TaskModel extends Task {
  const TaskModel({
    super.id = -1,
    super.localId = 0,
    required super.title,
    super.isCompleted,
    super.isLocalEdit = false,
    super.isDeleted = false,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'] as int? ?? -1,
      title: json['title'] as String,
      isCompleted: json['completed'] as bool? ?? false,
      isLocalEdit: false,
      isDeleted: false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id == -1 ? null : id,
      'title': title,
      'completed': isCompleted,
    };
  }

  static List<TaskModel> fromJsonList(List<dynamic> jsonList) {
    return jsonList
        .map((json) => TaskModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  factory TaskModel.fromEntity(
    Task task, {
    int? id,
    int? localId,
    bool? isLocalEdit,
    bool? isDeleted,
  }) {
    return TaskModel(
      id: id ?? task.id,
      title: task.title,
      isCompleted: task.isCompleted,
      localId: localId ?? task.localId,
      isLocalEdit: isLocalEdit ?? task.isLocalEdit,
      isDeleted: isDeleted ?? task.isDeleted,
    );
  }

  // SQLite helper methods
  Map<String, dynamic> toMap() {
    return {
      if (localId != 0) 'localId': localId,
      'id': id,
      'title': title,
      'isCompleted': isCompleted ? 1 : 0,
      'isLocalEdit': isLocalEdit ? 1 : 0,
      'isDeleted': isDeleted ? 1 : 0,
    };
  }

  factory TaskModel.fromMap(Map<String, dynamic> map) {
    return TaskModel(
      localId: map['localId'] as int? ?? 0,
      id: map['id'] as int? ?? -1,
      title: map['title'] as String,
      isCompleted: map['isCompleted'] == 1,
      isLocalEdit: map['isLocalEdit'] == 1,
      isDeleted: map['isDeleted'] == 1,
    );
  }

  @override
  TaskModel copyWith({
    int? id,
    int? localId,
    String? title,
    bool? isCompleted,
    bool? isLocalEdit,
    bool? isDeleted,
  }) {
    return TaskModel(
      id: id ?? this.id,
      localId: localId ?? this.localId,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      isLocalEdit: isLocalEdit ?? this.isLocalEdit,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }
}
