import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:common_components/src/short_code/domain/usecase/short_code_usecase.dart';
import 'package:dartz/dartz.dart';
import 'package:common_components/src/short_code/model/request/short_code_request_model.dart';

final shortCodeControllerProvider = Provider<ShortCodeController>(
  (ref) =>
      ShortCodeController(shortCodeUsecase: ref.read(shortCodeUseCaseProvider)),
);

class ShortCodeController {
  ShortCodeUsecase shortCodeUsecase;

  ShortCodeController({required this.shortCodeUsecase});

  Future<Either<Exception, String?>> getShortCode() async {
    ShortCodeRequestModel params = ShortCodeRequestModel(

    deviceInfo: DeviceInfo(
      userAgent: '',
      platform: '',
    ),
    metadata: Metadata(
      purpose: '',
      appVersion: '',
    ),
    ttlSeconds: 60

    );

    final res = await shortCodeUsecase(params);

    return res.fold((l) => Left(l), (r) => Right(r.data?.ottToken));
  }
}
