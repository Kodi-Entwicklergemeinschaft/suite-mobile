import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:network/network.dart';

import 'package:common_components/src/constants/common_api_endpoints.dart';
import 'package:common_components/src/image_upload/model/request/image_upload_request_model.dart';
import 'package:common_components/src/image_upload/model/request/image_delete_request_model.dart';
import 'package:common_components/src/image_upload/model/response/image_upload_response_model.dart';

final imageUploadServiceProvider = Provider<ImageUploadService>(
  (ref) => ImageUploadService(apiHelper: ref.read(apiHelperProvider)),
);

class ImageUploadService {
  ApiHelper apiHelper;
  ImageUploadService({required this.apiHelper});

  Future<Either<Exception, ImageUploadResponseModel>> uploadImage(ImageUploadRequestModel params) async {
    final path = params.filePath!;
    final filename = path.contains(RegExp(r'[/\\]')) ? path.split(RegExp(r'[/\\]')).last : path;
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(path, filename: filename),
      'entityType': params.entityType ?? '',
      'mediaType': params.mediaType ?? '',
    });
    final response = await apiHelper.postFormRequest<ImageUploadResponseModel>(
      path: CommonApiEndpoints.imageUpload,
      create: () => ImageUploadResponseModel(),
      body: formData,
    );
    return response.fold((l) => Left(l), (r) => Right(r));
  }

  Future<Either<Exception, void>> deleteImage(ImageDeleteRequestModel params) async {
    final response = await apiHelper.deleteRequest<ImageUploadResponseModel>(
      path: CommonApiEndpoints.imageDelete,
      create: () => ImageUploadResponseModel(),
      body: params.toJson(),
    );
    return response.fold((l) => Left(l), (_) => const Right(null));
  }
}
