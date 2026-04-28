import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/network/network_service.dart';
import '../../../../core/error/failures.dart';

abstract class TodoRemoteDataSource {
  Future<Either<Failure, Response>> getTasks({String? query});
  Future<Either<Failure, Response>> addTask(Map<String, dynamic> data);
  Future<Either<Failure, Response>> updateTask(
    int id,
    Map<String, dynamic> data,
  );
  Future<Either<Failure, Response>> deleteTask(int id);
}

class TodoRemoteDataSourceImpl implements TodoRemoteDataSource {
  final NetworkService networkService;

  TodoRemoteDataSourceImpl({required this.networkService});

  @override
  Future<Either<Failure, Response>> getTasks({String? query}) {
    final Map<String, dynamic> queryParams = {};
    if (query != null && query.isNotEmpty) {
      queryParams['q'] = query;
    }
    return networkService.get('/todos', queryParameters: queryParams);
  }

  @override
  Future<Either<Failure, Response>> addTask(Map<String, dynamic> data) {
    return networkService.post('/todos', data: data);
  }

  @override
  Future<Either<Failure, Response>> updateTask(
    int id,
    Map<String, dynamic> data,
  ) {
    return networkService.put('/todos/$id', data: data);
  }

  @override
  Future<Either<Failure, Response>> deleteTask(int id) {
    return networkService.delete('/todos/$id');
  }
}
