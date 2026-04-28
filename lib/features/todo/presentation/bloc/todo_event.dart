part of 'todo_bloc.dart';

abstract class TodoEvent extends Equatable {
  const TodoEvent();

  @override
  List<Object> get props => [];
}

class LoadTodos extends TodoEvent {}

class LoadMoreTodos extends TodoEvent {}

class SearchTodos extends TodoEvent {
  final String query;
  const SearchTodos(this.query);

  @override
  List<Object> get props => [query];
}

class AddTodo extends TodoEvent {
  final String title;
  const AddTodo(this.title);

  @override
  List<Object> get props => [title];
}

class DeleteTodo extends TodoEvent {
  final int id;
  final int localId;
  const DeleteTodo({this.id = -1, required this.localId});

  @override
  List<Object> get props => [id, localId];
}

class UpdateTodo extends TodoEvent {
  final Task task;
  const UpdateTodo(this.task);

  @override
  List<Object> get props => [task];
}
