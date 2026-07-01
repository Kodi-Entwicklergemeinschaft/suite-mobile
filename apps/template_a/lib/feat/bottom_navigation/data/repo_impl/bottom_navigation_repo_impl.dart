import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:network/network.dart';
import 'package:template_a/feat/bottom_navigation/data/service/bottom_navigation_service.dart';
import 'package:template_a/feat/bottom_navigation/domain/repository/bottom_navigation_repo.dart';

final bottomNavigationRepoImplProvider = Provider(
  (ref) => BottomNavigationRepoImpl(
    bottomNavigationService: ref.read(bottomNavigationServiceProvider),
  ),
);

class BottomNavigationRepoImpl implements BottomNavigationRepo {
  BottomNavigationService bottomNavigationService;
  BottomNavigationRepoImpl({required this.bottomNavigationService});

  @override
  Future<Either<Exception, BaseModel>> getBottomNavigationConfig({
    required BaseModel params,
  }) async {
    final result = await bottomNavigationService.getBottomNavigationConfig(
      params: params,
    );
    return result.fold((l) => Left(l), (r) => Right(r));
  }
}
