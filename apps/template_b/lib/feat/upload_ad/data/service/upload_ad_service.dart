import 'package:network/network.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final uploadAdServiceProvider = Provider(
  (ref) => UploadAdService(apiHelper: ref.read(apiHelperProvider)),
);

class UploadAdService {
  ApiHelper apiHelper;

  UploadAdService({required this.apiHelper});

  Future<Either<Exception, BaseModel>> getUploadAdConfig(
    BaseModel params,
  ) async {
    return Left(Exception());
  }

  Future<Either<Exception, BaseModel>> uploadAd(BaseModel params) async {
    return Left(Exception());
  }
}
