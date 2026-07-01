import 'package:network/network.dart';
import 'package:template_b/feat/bottom_navigation/data/repo_impl/bottom_navigation_repo_impl.dart';
import 'package:template_b/feat/bottom_navigation/domain/repository/bottom_navigation_repo.dart';
import 'package:template_b/feat/bottom_navigation/model/request_model/bottom_navigation_config_request_model.dart';
import 'package:template_b/feat/bottom_navigation/model/response_model/bottom_navigation_config_response_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final bottomNavigationUsecaseProvider = Provider(
  (ref) => BottomNavigationUsecase(
    bottomNavigationRepo: ref.read(bottomNavigationRepoImplProvider),
  ),
);

class BottomNavigationUsecase
    implements
        BaseUseCase<
          BottomNavigationConfigResponseModel,
          BottomNavigationConfigRequestModel
        > {
  BottomNavigationRepo bottomNavigationRepo;
  BottomNavigationUsecase({required this.bottomNavigationRepo});

  @override
  Future<Either<Exception, BottomNavigationConfigResponseModel>> call(
    BottomNavigationConfigRequestModel params,
  ) async {
    final res = await bottomNavigationRepo.getBottomNavigationConfig(params);
    return res.fold((l) => Left(l), (r) => Right(r));
  }
}
