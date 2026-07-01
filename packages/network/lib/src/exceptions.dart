import 'package:dio/dio.dart';

class ApiException extends DioException {
  ApiException({super.message, required super.requestOptions});

  @override
  String toString() {
    return message ?? 'error_unknown';
  }
}

class BadRequestException extends ApiException {
  BadRequestException({super.message, required super.requestOptions});

  @override
  String toString() {
    return message ?? 'error_bad_request';
  }
}

class InternalServerErrorException extends ApiException {
  InternalServerErrorException({super.message, required super.requestOptions});

  @override
  String toString() {
    return message ?? 'error_server_unavailable';
  }
}

class ConflictException extends ApiException {
  ConflictException({super.message, required super.requestOptions});

  @override
  String toString() {
    return message ?? 'error_conflict';
  }
}

class CancelException extends ApiException {
  CancelException({super.message, required super.requestOptions});

  @override
  String toString() {
    return message ?? 'error_request_cancelled';
  }
}

class UnauthorizedException extends ApiException {
  UnauthorizedException({super.message, required super.requestOptions});

  @override
  String toString() {
    return message ?? 'error_unauthorized';
  }
}

class NotFoundException extends ApiException {
  NotFoundException({super.message, required super.requestOptions});

  @override
  String toString() {
    return message ?? 'error_not_found';
  }
}

class NoInternetConnectionException extends ApiException {
  NoInternetConnectionException({super.message, required super.requestOptions});

  @override
  String toString() {
    return message ?? 'error_no_internet_connection';
  }
}

class DeadlineExceededException extends ApiException {
  DeadlineExceededException({super.message, required super.requestOptions});

  @override
  String toString() {
    return message ?? 'error_network_timeout';
  }
}

class UnknownException extends ApiException {
  UnknownException({super.message, required super.requestOptions});

  @override
  String toString() {
    return message ?? 'error_unknown';
  }
}

class ApiError implements Exception {
  ApiError({
    required this.error,
  });

  String error;

  @override
  String toString() {
    return error;
  }
}
