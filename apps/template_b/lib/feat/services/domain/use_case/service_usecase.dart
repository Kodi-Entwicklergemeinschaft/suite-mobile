import 'package:network/network.dart';
import 'package:template_b/feat/services/data/repo_impl/service_repo_impl.dart';
import 'package:template_b/feat/services/domain/repository/service_repo.dart';
import 'package:template_b/feat/services/model/request/get_service_config_request_model.dart';
import 'package:template_b/feat/services/model/response/get_service_config_response_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final serviceUsecaseProvider = Provider<ServiceUsecase>((ref) {
  return ServiceUsecase(serviceRepo: ref.read(serviceRepoImplProvider));
});

class ServiceUsecase
    implements
        BaseUseCase<
          GetServiceConfigResponseModel,
          GetServiceConfigRequestModel
        > {
  ServiceRepo serviceRepo;

  ServiceUsecase({required this.serviceRepo});

  @override
  Future<Either<Exception, GetServiceConfigResponseModel>> call(
    GetServiceConfigRequestModel params,
  ) async {
    final result = await serviceRepo.getServiceConfig(params);

    return result.fold((l) => Left(l), (r) => Right(r));
  }
}
