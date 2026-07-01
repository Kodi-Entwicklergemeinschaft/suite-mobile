import 'package:dio/dio.dart';
import 'package:dartz/dartz.dart';
import 'dio_factory.dart';
import 'base/base_model.dart';
import 'exceptions.dart';

class ApiHelper<E extends BaseModel> {
  final Dio _dio;

  get dio => _dio;
  CreateModel<E>? errorModel;
  final String fallbackErrorMessage;

  ApiHelper._internal(
    this._dio, {
    this.errorModel,
    required this.fallbackErrorMessage,
  });

  factory ApiHelper({
    required DioHelper dioHelper,
    CreateModel<E>? errorModel,
    String? fallbackErrorMessage,
  }) {
    return ApiHelper._internal(
      dioHelper.createDio(),
      fallbackErrorMessage: fallbackErrorMessage ??
          "Unknown error occurred, please try again later.",
      errorModel: errorModel,
    );
  }

  Future<Either<Exception, T>> postRequest<T extends BaseModel>({
    required String path,
    required CreateModel<T> create,
    CancelToken? cancelToken,
    Map<String, dynamic>? body,
    List<dynamic>? bodyList,
    Map<String, dynamic>? headers,
    ProgressCallback? onReceiveProgress,
  }) async {
    var response = await _dio
        .post(
      path,
      data: body ?? bodyList,
      options: Options(headers: headers),
      cancelToken: cancelToken,
      onReceiveProgress: onReceiveProgress,
    )
        .catchError((error) {
      String errorMessage = fallbackErrorMessage;

      if (error is DioException && error.response?.data != null) {
        final data = error.response!.data;
        if (data is Map<String, dynamic>) {
          errorMessage = data['message']
              ?? data['error']
              ?? data['detail']
              ?? fallbackErrorMessage;
        } else if (data is String) {
          errorMessage = data;
        }
      }

      return Response(
        requestOptions: RequestOptions(path: ''),
        statusMessage: errorMessage,
        statusCode: 999,
      );
    });
    if (response.statusCode == 999) {
      return Left(
          ApiError(error: response.statusMessage ?? fallbackErrorMessage));
    }
    try {
      if (response.data is String) {
        return Right(create().fromJson({"message": response.data}));
      }
      return Right(create().fromJson(response.data));
    } on Exception catch (e) {
      return Left(ApiError(
          error: errorModel != null
              ? errorModel!().fromJson(response.data).message
              : fallbackErrorMessage));
    } catch (error) {
      try {
        return Left(ApiError(
            error: errorModel != null
                ? errorModel!().fromJson(response.data).message
                : fallbackErrorMessage));
      } catch (error) {
        return Left(ApiError(error: fallbackErrorMessage));
      }
    }
  }

  Future<Either<Exception, T>> patchRequest<T extends BaseModel>({
    required String path,
    required CreateModel<T> create,
    CancelToken? cancelToken,
    Map<String, dynamic>? body,
    List<dynamic>? bodyList,
    Map<String, dynamic>? headers,
    ProgressCallback? onReceiveProgress,
  }) async {
    var response = await _dio
        .patch(
      path,
      data: body ?? bodyList,
      options: Options(headers: headers),
      cancelToken: cancelToken,
      onReceiveProgress: onReceiveProgress,
    )
        .catchError((error) {
      return Response(
        requestOptions: RequestOptions(path: ''),
        statusMessage: error.toString(),
        statusCode: 999,
      );
    });
    if (response.statusCode == 999) {
      return Left(
          ApiError(error: response.statusMessage ?? fallbackErrorMessage));
    }
    try {
      if (response.data is String) {
        return Right(create().fromJson({"message": response.data}));
      }
      return Right(create().fromJson(response.data));
    } on Exception catch (e) {
      return Left(e);
    } catch (error) {
      try {
        return Left(ApiError(
            error: errorModel != null
                ? errorModel!().fromJson(response.data).message
                : fallbackErrorMessage));
      } catch (error) {
        return Left(ApiError(error: fallbackErrorMessage));
      }
    }
  }

  Future<Either<Exception, T>> postFormRequest<T extends BaseModel>({
    required String path,
    required CreateModel<T> create,
    CancelToken? cancelToken,
    FormData? body,
    Map<String, dynamic>? headers,
    ProgressCallback? onReceiveProgress,
  }) async {
    var response = await _dio
        .post(
      path,
      data: body,
      options: Options(headers: headers),
      cancelToken: cancelToken,
      onReceiveProgress: onReceiveProgress,
    )
        .catchError((error) {
      return Response(
        requestOptions: RequestOptions(path: ''),
        statusMessage: error.toString(),
        statusCode: 999,
      );
    });
    if (response.statusCode == 999) {
      return Left(
          ApiError(error: response.statusMessage ?? fallbackErrorMessage));
    }
    try {
      if (response.data is String) {
        return Right(create().fromJson({"message": response.data}));
      }
      return Right(create().fromJson(response.data));
    } on Exception catch (e) {
      return Left(e);
    } catch (error) {
      try {
        return Left(ApiError(
            error: errorModel != null
                ? errorModel!().fromJson(response.data).message
                : fallbackErrorMessage));
      } catch (error) {
        return Left(ApiError(error: fallbackErrorMessage));
      }
    }
  }

  Future<Either<Exception, List<T>>> postListRequest<T extends BaseModel>({
    required String path,
    required CreateModel<T> create,
    CancelToken? cancelToken,
    Map<String, dynamic>? body,
    Map<String, dynamic>? headers,
    ProgressCallback? onReceiveProgress,
  }) async {
    var response = await _dio
        .post(
      path,
      data: body,
      options: Options(headers: headers),
      cancelToken: cancelToken,
      onReceiveProgress: onReceiveProgress,
    )
        .catchError((error) {
      return Response(
        requestOptions: RequestOptions(path: ''),
        statusMessage: error.toString(),
        statusCode: 999,
      );
    });
    if (response.statusCode == 999) {
      return Left(
          ApiError(error: response.statusMessage ?? fallbackErrorMessage));
    }
    try {
      if (response.data is String) {
        return Right(create().fromJson({"message": response.data}));
      }
      if (response.data is List) {
        return Right((response.data as List)
            .map<T>((e) => create().fromJson(e))
            .toList());
      } else {
        return Left(ApiError(error: "Response is not list type"));
      }
    } on Exception catch (e) {
      return Left(e);
    } catch (error) {
      try {
        return Left(ApiError(
            error: errorModel != null
                ? errorModel!().fromJson(response.data).message
                : fallbackErrorMessage));
      } catch (error) {
        return Left(ApiError(error: fallbackErrorMessage));
      }
    }
  }

  Future<Either<Exception, T>> getRequest<T extends BaseModel>({
    required String path,
    required CreateModel<T> create,
    CancelToken? cancelToken,
    Map<String, dynamic>? params,
    Map<String, dynamic>? body,
    Map<String, dynamic>? headers,
    ProgressCallback? onReceiveProgress,
  }) async {
    var response = await _dio
        .get(
      path,
      queryParameters: params,
      data: body,
      options: Options(headers: headers),
      cancelToken: cancelToken,
      onReceiveProgress: onReceiveProgress,
    )
        .catchError((error) {
      return Response(
        requestOptions: RequestOptions(path: ''),
        statusMessage: error.toString(),
        statusCode: 999,
      );
    });
    try {
      if (response.data is String) {
        return Right(create().fromJson({"message": response.data}));
      }
      return Right(create().fromJson(response.data));
    } on Exception catch (e) {
      return Left(e);
    } catch (error) {
      try {
        return Left(ApiError(
            error: errorModel != null
                ? errorModel!().fromJson(response.data).message
                : fallbackErrorMessage));
      } catch (error) {
        return Left(ApiError(error: fallbackErrorMessage));
      }
    }
  }

  Future<Either<Exception, T>> getFormRequest<T extends BaseModel>({
    required String path,
    required CreateModel<T> create,
    CancelToken? cancelToken,
    FormData? params,
    Map<String, dynamic>? headers,
    ProgressCallback? onReceiveProgress,
  }) async {
    var response = await _dio
        .get(
      path,
      data: params,
      options: Options(headers: headers),
      cancelToken: cancelToken,
      onReceiveProgress: onReceiveProgress,
    )
        .catchError((error) {
      return Response(
        requestOptions: RequestOptions(path: ''),
        statusMessage: error.toString(),
        statusCode: 999,
      );
    });
    try {
      if (response.data is String) {
        return Right(create().fromJson({"message": response.data}));
      }
      return Right(create().fromJson(response.data));
    } on Exception catch (e) {
      return Left(e);
    } catch (error) {
      try {
        return Left(ApiError(
            error: errorModel != null
                ? errorModel!().fromJson(response.data).message
                : fallbackErrorMessage));
      } catch (error) {
        return Left(ApiError(error: fallbackErrorMessage));
      }
    }
  }

  Future<Either<Exception, List<T>>> getListRequest<T extends BaseModel>({
    required String path,
    required CreateModel<T> create,
    CancelToken? cancelToken,
    Map<String, dynamic>? params,
    Map<String, dynamic>? headers,
    ProgressCallback? onReceiveProgress,
  }) async {
    var response = await _dio
        .get(
      path,
      queryParameters: params,
      options: Options(headers: headers),
      cancelToken: cancelToken,
      onReceiveProgress: onReceiveProgress,
    )
        .catchError((error) {
      return Response(
        requestOptions: RequestOptions(path: ''),
        statusMessage: error.toString(),
        statusCode: 999,
      );
    });
    try {
      if (response.data is String) {
        return Right(create().fromJson({"message": response.data}));
      }
      if (response.data is List) {
        return Right((response.data as List)
            .map<T>((e) => create().fromJson(e))
            .toList());
      } else {
        return Left(ApiError(error: "Response is not list type"));
      }
    } on Exception catch (e) {
      return Left(e);
    } catch (error) {
      try {
        return Left(ApiError(
            error: errorModel != null
                ? errorModel!().fromJson(response.data).message
                : fallbackErrorMessage));
      } catch (error) {
        return Left(ApiError(error: fallbackErrorMessage));
      }
    }
  }

  Future<Either<Exception, List<String>>>
      getStringListRequest<T extends BaseModel>({
    required String path,
    CancelToken? cancelToken,
    Map<String, dynamic>? params,
    Map<String, dynamic>? headers,
    ProgressCallback? onReceiveProgress,
  }) async {
    var response = await _dio
        .get(
      path,
      queryParameters: params,
      options: Options(headers: headers),
      cancelToken: cancelToken,
      onReceiveProgress: onReceiveProgress,
    )
        .catchError((error) {
      return Response(
        requestOptions: RequestOptions(path: ''),
        statusMessage: error.toString(),
        statusCode: 999,
      );
    });
    try {
      if (response.data is List) {
        return Right(
            (response.data as List).map<String>((e) => e.toString()).toList());
      } else {
        return Left(ApiError(error: "Response is not list type"));
      }
    } on Exception catch (e) {
      return Left(e);
    } catch (error) {
      try {
        return Left(ApiError(
            error: errorModel != null
                ? errorModel!().fromJson(response.data).message
                : fallbackErrorMessage));
      } catch (error) {
        return Left(ApiError(error: fallbackErrorMessage));
      }
    }
  }

  Future<Either<Exception, List<int>>> getByteArray({
    required String path,
    CancelToken? cancelToken,
    Map<String, dynamic>? body,
    Map<String, dynamic>? params,
    Map<String, dynamic>? headers,
    ProgressCallback? onReceiveProgress,
  }) async {
    var response = await Dio().post<List<int>>(
      path,
      data: body,
      options: Options(responseType: ResponseType.bytes),
    );
    try {
      if (response.data != null && response.data is List<int>) {
        return Right(response.data!);
      } else {
        return Left(ApiError(error: "Response is not list type"));
      }
    } on Exception catch (e) {
      return Left(e);
    } catch (error) {
      return Left(ApiError(error: fallbackErrorMessage));
    }
  }

  Future<Either<Exception, T>> putRequest<T extends BaseModel>({
    required String path,
    required CreateModel<T> create,
    CancelToken? cancelToken,
    Map<String, dynamic>? body,
    Map<String, dynamic>? headers,
    ProgressCallback? onReceiveProgress,
  }) async {
    var response = await _dio
        .put(
      path,
      data: body,
      options: Options(headers: headers),
      cancelToken: cancelToken,
      onReceiveProgress: onReceiveProgress,
    )
        .catchError((error) {
      return Response(
        requestOptions: RequestOptions(path: ''),
        statusMessage: error.toString(),
        statusCode: 999,
      );
    });
    if (response.statusCode == 999) {
      return Left(ApiError(error: fallbackErrorMessage));
    }
    try {
      if (response.data is String) {
        return Right(create().fromJson({"message": response.data}));
      }
      return Right(create().fromJson(response.data));
    } on Exception catch (e) {
      return Left(e);
    } catch (error) {
      try {
        return Left(ApiError(
            error: errorModel != null
                ? errorModel!().fromJson(response.data).message
                : fallbackErrorMessage));
      } catch (error) {
        return Left(ApiError(error: fallbackErrorMessage));
      }
    }
  }

  Future<Either<Exception, T>> deleteRequest<T extends BaseModel>({
    required String path,
    required CreateModel<T> create,
    CancelToken? cancelToken,
    Map<String, dynamic>? body,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? queryParameters,
    ProgressCallback? onReceiveProgress,
  }) async {
    var response = await _dio
        .delete(
      path,
      data: body,
      queryParameters: queryParameters,
      options: Options(headers: headers),
      cancelToken: cancelToken,
    )
        .catchError((error) {
      return Response(
        requestOptions: RequestOptions(path: ''),
        statusMessage: error.toString(),
        statusCode: 999,
      );
    });

    if (response.statusCode == 999) {
      return Left(
          ApiError(error: response.statusMessage ?? fallbackErrorMessage));
    }

    try {
      if (response.data is String) {
        return Right(create().fromJson({"message": response.data}));
      }

      // For DELETE requests, sometimes the response might be empty
      // Handle cases where there's no response body but the request was successful
      if (response.data == null) {
        // You might want to return a success message or empty model
        // This depends on your API design
        return Right(create().fromJson({"success": true}));
      }

      return Right(create().fromJson(response.data));
    } on Exception catch (e) {
      return Left(e);
    } catch (error) {
      try {
        return Left(ApiError(
            error: errorModel != null
                ? errorModel!().fromJson(response.data).message
                : fallbackErrorMessage));
      } catch (error) {
        return Left(ApiError(error: fallbackErrorMessage));
      }
    }
  }
}
