import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:common_components/src/image_upload/data/service/image_upload_service.dart';
import 'package:common_components/src/image_upload/domain/repository/image_upload_repo.dart';
import 'package:common_components/src/image_upload/model/request/image_upload_request_model.dart';
import 'package:common_components/src/image_upload/model/request/image_delete_request_model.dart';
import 'package:common_components/src/image_upload/model/response/image_upload_response_model.dart';

final imageUploadRepoImplProvider = Provider<ImageUploadRepo>(
  (ref) => ImageUploadRepoImpl(imageUploadService: ref.read(imageUploadServiceProvider)),
);

class ImageUploadRepoImpl implements ImageUploadRepo {
  ImageUploadService imageUploadService;

  ImageUploadRepoImpl({required this.imageUploadService});

  @override
  Future<Either<Exception, ImageUploadResponseModel>> uploadImage(ImageUploadRequestModel params) async {
    final res = await imageUploadService.uploadImage(params);
    return res.fold((l) => Left(l), (r) => Right(r));
  }

  @override
  Future<Either<Exception, void>> deleteImage(ImageDeleteRequestModel params) async {
    return imageUploadService.deleteImage(params);
  }
}
