import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:network/network.dart';

import 'package:common_components/src/image_upload/data/repo_impl/image_upload_repo_impl.dart';
import 'package:common_components/src/image_upload/domain/repository/image_upload_repo.dart';
import 'package:common_components/src/image_upload/model/request/image_delete_request_model.dart';

final profileImageDeleteUsecaseProvider = Provider<ProfileImageDeleteUsecase>(
  (ref) => ProfileImageDeleteUsecase(imageUploadRepo: ref.read(imageUploadRepoImplProvider)),
);

class ProfileImageDeleteUsecase implements BaseUseCase<void, ImageDeleteRequestModel> {
  final ImageUploadRepo imageUploadRepo;

  ProfileImageDeleteUsecase({required this.imageUploadRepo});

  @override
  Future<Either<Exception, void>> call(ImageDeleteRequestModel params) {
    return imageUploadRepo.deleteImage(params);
  }
}
