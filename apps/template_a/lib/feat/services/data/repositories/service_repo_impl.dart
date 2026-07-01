import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/service_repo.dart';
import '../models/get_service_config_request_model.dart';
import '../models/get_service_config_response_model.dart';
import '../services/service.dart';

final serviceRepoProvider = Provider<ServiceRepo>((ref) {
  return ServiceRepoImpl(service: ref.read(serviceProvider));
});

class ServiceRepoImpl implements ServiceRepo {
  final Service service;

  ServiceRepoImpl({required this.service});

  @override
  Future<Either<Exception, GetServiceConfigResponseModel>> getServiceConfig(
    GetServiceConfigRequestModel params,
  ) {
    return service.getServiceConfig(params);
  }
}
