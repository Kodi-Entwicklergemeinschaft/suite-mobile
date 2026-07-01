import 'package:network/network.dart';
import 'package:template_c/feat/bottom_navigation/data/repo_impl/bottom_navigation_repo_impl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:template_c/feat/bottom_navigation/domain/repo/bottom_navigation_repo.dart';

final bottomNavigationUseCaseProvider = Provider(
  (ref) => BottomNavigationUsecase(
    bottomNavigationRepo: ref.read(bottomNavigationRepoImplProvider),
  ),
);

class BottomNavigationUsecase implements BaseUseCase<BaseModel, BaseModel> {
  BottomNavigationRepo bottomNavigationRepo;

  BottomNavigationUsecase({required this.bottomNavigationRepo});

  @override
  Future<Either<Exception, BaseModel<dynamic>>> call(
    BaseModel<dynamic> params,
  ) async {
    final result = await bottomNavigationRepo.getBottomNavigationConfig(
      params: params,
    );

    return result.fold((l) => Left(l), (r) => Right(r));
  }
}
