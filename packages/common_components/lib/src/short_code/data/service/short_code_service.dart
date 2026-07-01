import 'package:network/network.dart';
import 'package:dartz/dartz.dart';
import 'package:common_components/src/constants/common_api_endpoints.dart';
import 'package:common_components/src/short_code/model/request/short_code_request_model.dart';
import 'package:common_components/src/short_code/model/response/short_code_response_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final shortCodeServiceProvider = Provider<ShortCodeService>(
  (ref) => ShortCodeService(apiHelper: ref.read(apiHelperProvider)),
);

class ShortCodeService {
  ApiHelper apiHelper;

  ShortCodeService({required this.apiHelper});

  Future<Either<Exception, ShortCodeResponseModel>> getShortCode(
    ShortCodeRequestModel params,
  ) async {
    final response = await apiHelper.postRequest(
      path: CommonApiEndpoints.shortCodeConfig,
      create: () => ShortCodeResponseModel(),
      body: params.toJson(),
    );

    return response.fold((l) => Left(l), (r) => Right(r));
  }
}
