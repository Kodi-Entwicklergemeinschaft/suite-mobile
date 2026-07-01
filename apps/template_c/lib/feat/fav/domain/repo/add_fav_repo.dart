import 'package:dartz/dartz.dart';
import 'package:template_c/feat/fav/data/model/request_model/add_fav_request_model.dart';
import 'package:template_c/feat/fav/data/model/response_model/add_fav_response_model.dart';

abstract class AddFavRepo {
  Future<Either<Exception, AddFavResponseModel>> addFav(
    AddFavRequestModel request,
  );
}

