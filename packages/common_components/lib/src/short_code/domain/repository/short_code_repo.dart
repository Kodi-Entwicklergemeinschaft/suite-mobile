import 'package:dartz/dartz.dart';
import 'package:common_components/src/short_code/model/request/short_code_request_model.dart';
import 'package:common_components/src/short_code/model/response/short_code_response_model.dart';

abstract class ShortCodeRepo {
  Future<Either<Exception, ShortCodeResponseModel>> getShortCode(
    ShortCodeRequestModel params,
  );
}
