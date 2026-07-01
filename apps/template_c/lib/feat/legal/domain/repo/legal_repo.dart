import 'package:dartz/dartz.dart';
import 'package:template_c/feat/legal/model/request/legal_request_model.dart';
import 'package:template_c/feat/legal/model/response/legal_response_model.dart';
abstract class LegalRepo {
  Future<Either<Exception, LegalResponseModel>> getLegalConfig(
    LegalRequestModel params,
  );
}
