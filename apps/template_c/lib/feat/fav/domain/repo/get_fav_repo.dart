import 'package:dartz/dartz.dart';
import 'package:template_c/feat/fav/data/model/request_model/get_fav_listing_date_request_model.dart';
import 'package:template_c/feat/fav/data/model/request_model/get_fav_request_model.dart';
import 'package:template_c/feat/fav/data/model/response_model/get_fav_categories_response_model.dart';
import 'package:template_c/feat/fav/data/model/response_model/get_fav_listing_date_response_model.dart';
import 'package:template_c/feat/fav/data/model/response_model/get_fav_response_model.dart';

abstract class GetFavRepo {
  Future<Either<Exception, GetFavResponseModel>> getFav(
    GetFavRequestModel request,
  );

  Future<Either<Exception, GetFavListingDateResponseModel>> getFavListingDate(
    GetFavListingDateRequestModel request,
  );

  Future<Either<Exception, GetFavCategoriesResponseModel>> getFavCategories();
}
