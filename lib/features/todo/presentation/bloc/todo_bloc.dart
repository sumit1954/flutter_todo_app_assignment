import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/task.dart';
import '../../domain/repositories/todo_repository.dart';

part 'todo_event.dart';
part 'todo_state.dart';

class TodoBloc extends Bloc<TodoEvent, TodoState> {
  final TodoRepository todoRepository;

  TodoBloc({required this.todoRepository}) : super(TodoInitial()) {
    on<LoadTodos>(_onLoadTodos);
    on<SearchTodos>(_onSearchTodos);
    on<AddTodo>(_onAddTodo);
    on<UpdateTodo>(_onUpdateTodo);
    on<DeleteTodo>(_onDeleteTodo);
  }

  Future<void> _onLoadTodos(LoadTodos event, Emitter<TodoState> emit) async {
    emit(TodoLoading());
    final result = await todoRepository.getTasks();
    result.fold(
      (failure) => emit(TodoError(failure.message)),
      (tasks) => emit(TodoLoaded(tasks, hasReachedMax: true)),
    );
  }

  Future<void> _onSearchTodos(
    SearchTodos event,
    Emitter<TodoState> emit,
  ) async {
    emit(TodoLoading());
    final result = await todoRepository.getTasks(query: event.query);
    result.fold(
      (failure) => emit(TodoError(failure.message)),
      (tasks) => emit(
        TodoLoaded(tasks, hasReachedMax: true, searchQuery: event.query),
      ),
    );
  }

  Future<void> _onAddTodo(AddTodo event, Emitter<TodoState> emit) async {
    if (state is TodoLoaded) {
      final newTask = Task(title: event.title, isLocalEdit: true);

      final result = await todoRepository.addTask(newTask);
      result.fold(
        (failure) {
          emit(
            TodoMessage(message: failure.message, type: TodoMessageType.info),
          );
          add(LoadTodos());
        },
        (r) => add(LoadTodos()),
      );
    }
  }

  Future<void> _onUpdateTodo(UpdateTodo event, Emitter<TodoState> emit) async {
    if (state is TodoLoaded && event.task.localId != 0) {
      final localId = event.task.localId;

      // Prevent concurrent updates for the same task
      if ((state as TodoLoaded).processingIds.contains(localId)) return;

      final current = state as TodoLoaded;
      emit(
        current.copyWith(processingIds: {...current.processingIds, localId}),
      );

      final result = await todoRepository.updateTask(event.task);

      // Always get the latest state before emitting to avoid overwriting other processing tasks
      if (state is TodoLoaded) {
        final latest = state as TodoLoaded;
        final finalProcessingIds = Set<int>.from(latest.processingIds)
          ..remove(localId);

        result.fold(
          (failure) {
            emit(
              TodoMessage(message: failure.message, type: TodoMessageType.info),
            );
            final localTask = event.task.copyWith(isLocalEdit: true);
            emit(
              latest.copyWith(
                tasks: latest.tasks
                    .map((t) => t.localId == localId ? localTask : t)
                    .toList(),
                processingIds: finalProcessingIds,
              ),
            );
          },
          (_) {
            final syncedTask = event.task.copyWith(isLocalEdit: false);
            emit(
              latest.copyWith(
                tasks: latest.tasks
                    .map((t) => t.localId == localId ? syncedTask : t)
                    .toList(),
                processingIds: finalProcessingIds,
              ),
            );
          },
        );
      }
    }
  }

  Future<void> _onDeleteTodo(DeleteTodo event, Emitter<TodoState> emit) async {
    if (state is TodoLoaded && event.localId != 0) {
      final localId = event.localId;

      // Prevent concurrent deletes for the same task
      if ((state as TodoLoaded).processingIds.contains(localId)) return;

      final current = state as TodoLoaded;
      emit(
        current.copyWith(processingIds: {...current.processingIds, localId}),
      );

      final result = await todoRepository.deleteTask(
        id: event.id,
        localId: localId,
      );

      if (state is TodoLoaded) {
        final latest = state as TodoLoaded;
        final updatedTasks = latest.tasks
            .where((t) => t.localId != localId)
            .toList();
        final finalProcessingIds = Set<int>.from(latest.processingIds)
          ..remove(localId);

        result.fold(
          (failure) {
            emit(
              TodoMessage(message: failure.message, type: TodoMessageType.info),
            );
            emit(
              latest.copyWith(
                tasks: updatedTasks,
                processingIds: finalProcessingIds,
              ),
            );
          },
          (_) {
            emit(
              latest.copyWith(
                tasks: updatedTasks,
                processingIds: finalProcessingIds,
              ),
            );
          },
        );
      }
    }
  }
}
