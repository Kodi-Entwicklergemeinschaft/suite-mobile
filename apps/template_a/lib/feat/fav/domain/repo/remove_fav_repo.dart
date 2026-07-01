import 'package:dartz/dartz.dart';
import 'package:template_a/feat/fav/data/model/request_model/remove_fav_request_model.dart';
import 'package:template_a/feat/fav/data/model/response_model/remove_fav_response_model.dart';

abstract class RemoveFavRepo {
  Future<Either<Exception, RemoveFavResponseModel>> removeFav(RemoveFavRequestModel request);
}
