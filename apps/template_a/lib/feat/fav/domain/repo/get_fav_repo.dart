import 'package:dartz/dartz.dart';
import 'package:template_a/feat/fav/data/model/request_model/get_fav_request_model.dart';
import 'package:template_a/feat/fav/data/model/response_model/get_fav_response_model.dart';

abstract class GetFavRepo {
  Future<Either<Exception, GetFavResponseModel>> getFav(GetFavRequestModel request);
}
