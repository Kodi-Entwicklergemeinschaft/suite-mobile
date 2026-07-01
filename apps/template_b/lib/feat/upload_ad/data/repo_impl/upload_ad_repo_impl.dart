import 'package:dartz/dartz.dart';
import 'package:network/src/base/base_model.dart';
import 'package:template_b/feat/upload_ad/data/service/upload_ad_service.dart';
import 'package:template_b/feat/upload_ad/domain/repo/upload_ad_repo.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final uploadAdRepoImplProvider = Provider((ref)=>UploadAdRepoImpl(uploadAdService: ref.read(uploadAdServiceProvider)));

class UploadAdRepoImpl implements UploadAdRepo {
  UploadAdService uploadAdService;

  UploadAdRepoImpl({required this.uploadAdService});

  @override
  Future<Either<Exception, BaseModel<dynamic>>> getUploadAdConfig(
    BaseModel<dynamic> params,
  ) async {
    final res = await uploadAdService.getUploadAdConfig(params);
    return res.fold((l) => Left(l), (r) => Right(r));
  }

  @override
  Future<Either<Exception, BaseModel<dynamic>>> uploadAd(
    BaseModel<dynamic> params,
  ) async{
     final res = await uploadAdService.uploadAd(params);
    return res.fold((l) => Left(l), (r) => Right(r));
  }
}
