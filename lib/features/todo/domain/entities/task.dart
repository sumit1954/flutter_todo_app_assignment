import 'package:equatable/equatable.dart';

class Task extends Equatable {
  final int id;
  final int localId;
  final String title;
  final bool isCompleted;
  final bool isLocalEdit;
  final bool isDeleted;

  const Task({
    this.id = -1,
    this.localId = 0,
    required this.title,
    this.isCompleted = false,
    this.isLocalEdit = false,
    this.isDeleted = false,
  });

  Task copyWith({
    int? id,
    int? localId,
    String? title,
    bool? isCompleted,
    bool? isLocalEdit,
    bool? isDeleted,
  }) {
    return Task(
      id: id ?? this.id,
      localId: localId ?? this.localId,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      isLocalEdit: isLocalEdit ?? this.isLocalEdit,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  @override
  List<Object?> get props => [
    id,
    localId,
    title,
    isCompleted,
    isLocalEdit,
    isDeleted,
  ];
}
