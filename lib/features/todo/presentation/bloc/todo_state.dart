part of 'todo_bloc.dart';

enum TodoMessageType { info, warning, error }

abstract class TodoState extends Equatable {
  const TodoState();

  @override
  List<Object> get props => [];
}

class TodoInitial extends TodoState {}

class TodoLoading extends TodoState {}

class TodoLoaded extends TodoState {
  final List<Task> tasks;
  final Set<int> processingIds;
  final int currentPage;
  final bool hasReachedMax;
  final String searchQuery;

  const TodoLoaded(
    this.tasks, {
    this.processingIds = const {},
    this.currentPage = 1,
    this.hasReachedMax = false,
    this.searchQuery = '',
  });

  int get totalTasks => tasks.length;
  int get completedTasks => tasks.where((t) => t.isCompleted).length;
  int get pendingTasks => totalTasks - completedTasks;

  TodoLoaded copyWith({
    List<Task>? tasks,
    Set<int>? processingIds,
    int? currentPage,
    bool? hasReachedMax,
    String? searchQuery,
  }) {
    return TodoLoaded(
      tasks ?? this.tasks,
      processingIds: processingIds ?? this.processingIds,
      currentPage: currentPage ?? this.currentPage,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object> get props => [
    tasks,
    processingIds,
    currentPage,
    hasReachedMax,
    searchQuery,
  ];
}

class TodoMessage extends TodoState {
  final String message;
  final TodoMessageType type;

  const TodoMessage({required this.message, required this.type});

  @override
  List<Object> get props => [message, type];
}

class TodoError extends TodoState {
  final String message;
  const TodoError(this.message);

  @override
  List<Object> get props => [message];
}
