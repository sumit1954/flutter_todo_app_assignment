import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:dartz/dartz.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../error/failures.dart';

class NetworkService {
  late final Dio _dio;

  NetworkService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: 'https://jsonplaceholder.typicode.com',
        contentType: 'application/json; charset=UTF-8',
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 3),
      ),
    );

    // Add Logger Interceptor
    _dio.interceptors.add(
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        error: true,
        compact: true,
        maxWidth: 90,
        logPrint: (object) =>
            debugPrint(object.toString()), // Force use of debugPrint
      ),
    );

    // Add a simple debug interceptor to verify it's working
    // _dio.interceptors.add(
    //   InterceptorsWrapper(
    //     onRequest: (options, handler) {
    //       debugPrint('--- Network Request: ${options.method} ${options.path} ---');
    //       return handler.next(options);
    //     },
    //     onResponse: (response, handler) {
    //       debugPrint('--- Network Response: ${response.statusCode} ${response.requestOptions.path} ---');
    //       return handler.next(response);
    //     },
    //     onError: (DioException e, handler) {
    //       debugPrint('--- Network Error: ${e.message} ---');
    //       return handler.next(e);
    //     },
    //   ),
    // );
  }

  Future<Either<Failure, Response>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    return _handleRequest(
      () => _dio.get(path, queryParameters: queryParameters),
    );
  }

  Future<Either<Failure, Response>> post(String path, {dynamic data}) async {
    return _handleRequest(() => _dio.post(path, data: data));
  }

  Future<Either<Failure, Response>> put(String path, {dynamic data}) async {
    return _handleRequest(() => _dio.put(path, data: data));
  }

  Future<Either<Failure, Response>> delete(String path) async {
    return _handleRequest(() => _dio.delete(path));
  }

  Future<Either<Failure, Response>> _handleRequest(
    Future<Response> Function() request,
  ) async {
    try {
      final response = await request();
      return Right(response);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Failure _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const NetworkFailure('Connection timed out');
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final message = _getMessageForStatusCode(statusCode);
        return NetworkFailure(message, statusCode: statusCode);
      case DioExceptionType.cancel:
        return const NetworkFailure('Request cancelled');
      default:
        return const NetworkFailure('Something went wrong');
    }
  }

  String _getMessageForStatusCode(int? statusCode) {
    if (statusCode == null) return 'Unknown error';
    if (statusCode >= 500) return 'Server error occurred';
    if (statusCode == 404) return 'Resource not found';
    if (statusCode == 401) return 'Unauthorized access';
    if (statusCode == 400) return 'Bad request';
    return 'Network error ($statusCode)';
  }
}
