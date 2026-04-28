import 'package:dartz/dartz.dart' hide Task;
import 'package:todo_assignment/core/error/failures.dart';
import '../entities/task.dart';

abstract class TodoRepository {
  Future<Either<Failure, List<Task>>> getTasks({String? query});
  Future<Either<Failure, void>> addTask(Task task);
  Future<Either<Failure, void>> updateTask(Task task);
  Future<Either<Failure, void>> deleteTask({
    required int id,
    required int localId,
  });
}
