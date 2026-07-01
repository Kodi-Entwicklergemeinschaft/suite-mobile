import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:network/network.dart';
import 'package:template_a/feat/fav/data/model/response_model/get_fav_categories_response_model.dart';
import 'package:template_a/feat/fav/data/repo_impl/get_fav_categories_repo_impl.dart';
import 'package:template_a/feat/fav/domain/repo/get_fav_categories_repo.dart';

final getFavCategoriesUseCaseProvider = Provider<GetFavCategoriesUseCase>(
  (ref) => GetFavCategoriesUseCase(
    repo: ref.watch(getFavCategoriesRepoProvider),
  ),
);

class GetFavCategoriesUseCase {
  final GetFavCategoriesRepo _repo;

  GetFavCategoriesUseCase({required GetFavCategoriesRepo repo}) : _repo = repo;

  Future<Either<Exception, GetFavCategoriesResponseModel>> call() {
    return _repo.getFavCategories();
  }
}
