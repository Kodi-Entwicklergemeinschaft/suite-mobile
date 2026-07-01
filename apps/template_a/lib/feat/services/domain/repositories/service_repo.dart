import 'package:dartz/dartz.dart';
import '../../data/models/get_service_config_request_model.dart';
import '../../data/models/get_service_config_response_model.dart';

abstract class ServiceRepo {
  Future<Either<Exception, GetServiceConfigResponseModel>> getServiceConfig(
    GetServiceConfigRequestModel params,
  );
}
