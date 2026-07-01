import 'package:network/network.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/get_service_config_request_model.dart';
import '../../data/models/get_service_config_response_model.dart';
import '../../data/repositories/service_repo_impl.dart';
import '../repositories/service_repo.dart';

final getServiceConfigUseCaseProvider = Provider<GetServiceConfigUseCase>((ref) {
  return GetServiceConfigUseCase(serviceRepo: ref.read(serviceRepoProvider));
});

class GetServiceConfigUseCase
    implements
        BaseUseCase<
          GetServiceConfigResponseModel,
          GetServiceConfigRequestModel
        > {
  final ServiceRepo serviceRepo;

  GetServiceConfigUseCase({required this.serviceRepo});

  @override
  Future<Either<Exception, GetServiceConfigResponseModel>> call(
    GetServiceConfigRequestModel params,
  ) {
    return serviceRepo.getServiceConfig(params);
  }
}
