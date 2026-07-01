import 'package:network/network.dart';
import 'package:template_b/feat/dashbboard/data/repo_impl/dashboard_repo_impl.dart';
import 'package:template_b/feat/dashbboard/domain/repo/dashboard_repo.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final dashboardUseCaseProvider = Provider(
  (ref) => DashboardUsecase(dashboardRepo: ref.read(dashboardRepoImplProvider)),
);

class DashboardUsecase implements BaseUseCase<BaseModel, BaseModel> {
  DashboardRepo dashboardRepo;

  DashboardUsecase({required this.dashboardRepo});
  @override
  Future<Either<Exception, BaseModel<dynamic>>> call(
    BaseModel<dynamic> params,
  ) async {
    final res = await dashboardRepo.getDashboardConfig(params);

    return res.fold((l) => Left(l), (r) => Right(r));
  }
}
