import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:network/network.dart';
import 'package:template_a/feat/fav/data/model/response_model/get_fav_categories_response_model.dart';
import 'package:template_a/feat/fav/data/service/get_fav_categories_service.dart';
import 'package:template_a/feat/fav/domain/repo/get_fav_categories_repo.dart';

final getFavCategoriesRepoProvider = Provider<GetFavCategoriesRepo>(
  (ref) => GetFavCategoriesRepoImpl(
    service: ref.watch(getFavCategoriesServiceProvider),
  ),
);

class GetFavCategoriesRepoImpl implements GetFavCategoriesRepo {
  final GetFavCategoriesService _service;

  GetFavCategoriesRepoImpl({required GetFavCategoriesService service})
      : _service = service;

  @override
  Future<Either<Exception, GetFavCategoriesResponseModel>>
      getFavCategories() {
    return _service.getFavCategories();
  }
}
