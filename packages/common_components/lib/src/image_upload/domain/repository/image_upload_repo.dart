import 'package:dartz/dartz.dart';

import 'package:common_components/src/image_upload/model/request/image_upload_request_model.dart';
import 'package:common_components/src/image_upload/model/request/image_delete_request_model.dart';
import 'package:common_components/src/image_upload/model/response/image_upload_response_model.dart';

abstract class ImageUploadRepo {
  Future<Either<Exception, ImageUploadResponseModel>> uploadImage(ImageUploadRequestModel params);
  Future<Either<Exception, void>> deleteImage(ImageDeleteRequestModel params);
}
