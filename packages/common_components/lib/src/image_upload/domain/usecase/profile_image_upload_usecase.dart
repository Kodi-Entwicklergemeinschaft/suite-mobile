import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:network/network.dart';

import 'package:common_components/src/image_upload/data/repo_impl/image_upload_repo_impl.dart';
import 'package:common_components/src/image_upload/domain/repository/image_upload_repo.dart';
import 'package:common_components/src/image_upload/model/request/image_upload_request_model.dart';
import 'package:common_components/src/image_upload/model/response/image_upload_response_model.dart';

final profileImageUploadUsecaseProvider = Provider<ProfileImageUploadUsecase>(
  (ref) => ProfileImageUploadUsecase(imageUploadRepo: ref.read(imageUploadRepoImplProvider)),
);

class ProfileImageUploadUsecase implements BaseUseCase<ImageUploadResponseModel, ImageUploadRequestModel> {
  ImageUploadRepo imageUploadRepo;

  ProfileImageUploadUsecase({required this.imageUploadRepo});

  @override
  Future<Either<Exception, ImageUploadResponseModel>> call(ImageUploadRequestModel params) async {
    final res = await imageUploadRepo.uploadImage(params);
    return res.fold((l) => Left(l), (r) => Right(r));
  }
}
