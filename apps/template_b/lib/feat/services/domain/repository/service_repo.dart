import 'package:dartz/dartz.dart';
import 'package:template_b/feat/services/model/request/get_service_config_request_model.dart';
import 'package:template_b/feat/services/model/response/get_service_config_response_model.dart';

abstract class ServiceRepo {
  Future<Either<Exception, GetServiceConfigResponseModel>> getServiceConfig(GetServiceConfigRequestModel params);
}
