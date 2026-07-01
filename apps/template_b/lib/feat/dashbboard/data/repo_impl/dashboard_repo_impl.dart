import 'package:dartz/dartz.dart';
import 'package:network/src/base/base_model.dart';
import 'package:template_b/feat/dashbboard/data/service/dashboard_service.dart';
import 'package:template_b/feat/dashbboard/domain/repo/dashboard_repo.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final dashboardRepoImplProvider = Provider(
  (ref) =>
      DashboardRepoImpl(dashboardService: ref.read(dashboardServiceProvider)),
);

class DashboardRepoImpl implements DashboardRepo {
  DashboardService dashboardService;

  DashboardRepoImpl({required this.dashboardService});

  @override
  Future<Either<Exception, BaseModel<dynamic>>> getDashboardConfig(
    BaseModel<dynamic> params,
  ) async {
    final res = await dashboardService.getDashBoardConfig(params);

    return res.fold((l) => Left(l), (r) => Right(r));
  }
}
