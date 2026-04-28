import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

class NetworkFailure extends Failure {
  final int? statusCode;
  const NetworkFailure(super.message, {this.statusCode});

  @override
  List<Object> get props => [message, statusCode ?? 0];
}

class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

class ServerFailure extends Failure {
  const ServerFailure(super.message);
}
