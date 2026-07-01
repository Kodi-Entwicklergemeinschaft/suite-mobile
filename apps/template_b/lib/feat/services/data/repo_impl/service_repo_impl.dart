import 'package:dartz/dartz.dart';
import 'package:template_b/feat/services/data/service/service.dart';
import 'package:template_b/feat/services/domain/repository/service_repo.dart';
import 'package:template_b/feat/services/model/request/get_service_config_request_model.dart';
import 'package:template_b/feat/services/model/response/get_service_config_response_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final serviceRepoImplProvider = Provider<ServiceRepoImpl>((
  ref,
) {
  return ServiceRepoImpl(service: ref.read(serviceProvider));
});

class ServiceRepoImpl implements ServiceRepo {
  final Service service;

  ServiceRepoImpl({required this.service});

  @override
  Future<Either<Exception, GetServiceConfigResponseModel>>
  getServiceConfig(GetServiceConfigRequestModel params) async {
    final result = await service.getServiceConfig(params);

    return result.fold((l) => Left(l), (r) => Right(r));
  }
}
