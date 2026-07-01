import 'package:dartz/dartz.dart';
import 'package:template_b/feat/bottom_navigation/data/service/bottom_navigation_service.dart';
import 'package:template_b/feat/bottom_navigation/domain/repository/bottom_navigation_repo.dart';
import 'package:template_b/feat/bottom_navigation/model/request_model/bottom_navigation_config_request_model.dart';
import 'package:template_b/feat/bottom_navigation/model/response_model/bottom_navigation_config_response_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final bottomNavigationRepoImplProvider = Provider(
  (ref) => BottomNavigationRepoImpl(
    bottomNavigationService: ref.read(bottomNavigationServiceProvider),
  ),
);

class BottomNavigationRepoImpl implements BottomNavigationRepo {
  BottomNavigationService bottomNavigationService;

  BottomNavigationRepoImpl({required this.bottomNavigationService});
  @override
  Future<Either<Exception, BottomNavigationConfigResponseModel>>
  getBottomNavigationConfig(BottomNavigationConfigRequestModel params) async {
    final res = await bottomNavigationService.getBottomNavigationConfig(params);
    return res.fold((l) => Left(l), (r) => Right(r));
  }
}
