import 'package:dio/dio.dart';
import 'exceptions.dart';

class ExceptionInterceptor extends Interceptor {
  ExceptionInterceptor();

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    String? message;

    if (err.response?.data != null) {
      if (err.response?.data is String) {
        message = err.response?.data;
      } else if (err.response?.data is Map<String, dynamic>) {
        final data = err.response?.data as Map<String, dynamic>;
        // Extract top-level message field
        message = data['message'] as String?;
      }
    }

    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        throw DeadlineExceededException(
            message: message, requestOptions: err.requestOptions);
      case DioExceptionType.badResponse:
        final statusCode = err.response?.statusCode ?? 0;
        switch (statusCode) {
          case 400:
            throw BadRequestException(
                message: message, requestOptions: err.requestOptions);
          case 401:
            throw UnauthorizedException(
                message: message, requestOptions: err.requestOptions);
          case 404:
            throw NotFoundException(requestOptions: err.requestOptions);
          case 409:
            throw ConflictException(
                message: message, requestOptions: err.requestOptions);
          default:
            if (statusCode >= 500) {
              throw InternalServerErrorException(
                requestOptions: err.requestOptions,
              );
            }
        }
        break;
      case DioExceptionType.connectionError:
        throw NoInternetConnectionException(
            message: message, requestOptions: err.requestOptions);
      case DioExceptionType.unknown:
        throw UnknownException(requestOptions: err.requestOptions);
      case DioExceptionType.badCertificate:
        throw BadRequestException(
            message: message, requestOptions: err.requestOptions);
      case DioExceptionType.cancel:
        throw CancelException(
            message: message, requestOptions: err.requestOptions);
    }

    return handler.next(err);
  }
}
