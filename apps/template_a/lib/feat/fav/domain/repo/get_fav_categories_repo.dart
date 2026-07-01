import 'package:network/network.dart';
import 'package:template_a/feat/fav/data/model/response_model/get_fav_categories_response_model.dart';

abstract class GetFavCategoriesRepo {
  Future<Either<Exception, GetFavCategoriesResponseModel>> getFavCategories();
}
