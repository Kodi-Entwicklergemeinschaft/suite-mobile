import 'package:network/network.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:template_b/feat/upload_ad/data/repo_impl/upload_ad_repo_impl.dart';
import 'package:template_b/feat/upload_ad/domain/repo/upload_ad_repo.dart';

final uploadAdUseCaseProvider = Provider(
  (ref) => UploadAdUsecase(uploadAdRepo: ref.read(uploadAdRepoImplProvider)),
);

class UploadAdUsecase implements BaseUseCase<BaseModel, BaseModel> {
  UploadAdRepo uploadAdRepo;

  UploadAdUsecase({required this.uploadAdRepo});

  @override
  Future<Either<Exception, BaseModel<dynamic>>> call(
    BaseModel<dynamic> params,
  ) async {
    final res = await uploadAdRepo.getUploadAdConfig(params);
    return res.fold((l) => Left(l), (r) => Right(r));
  }

  Future<Either<Exception, BaseModel<dynamic>>> uploadAd(
    BaseModel<dynamic> params,
  ) async {
    final res = await uploadAdRepo.uploadAd(params);
    return res.fold((l) => Left(l), (r) => Right(r));
  }
}
