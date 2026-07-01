import 'package:dartz/dartz.dart';
import 'package:common_components/src/short_code/data/service/short_code_service.dart';
import 'package:common_components/src/short_code/domain/repository/short_code_repo.dart';
import 'package:common_components/src/short_code/model/request/short_code_request_model.dart';
import 'package:common_components/src/short_code/model/response/short_code_response_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final shortCodeRepoProvider = Provider<ShortCodeRepo>(
  (ref) =>
      ShortCodeRepoImpl(shortCodeService: ref.read(shortCodeServiceProvider)),
);

class ShortCodeRepoImpl implements ShortCodeRepo {
  ShortCodeService shortCodeService;

  ShortCodeRepoImpl({required this.shortCodeService});

  @override
  Future<Either<Exception, ShortCodeResponseModel>> getShortCode(
    ShortCodeRequestModel params,
  ) async {
    final response = await shortCodeService.getShortCode(params);

    return response.fold((l) => Left(l), (r) => Right(r));
  }
}
