import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:template_a/feat/fav/data/model/request_model/get_fav_request_model.dart';
import 'package:template_a/feat/fav/data/model/response_model/get_fav_response_model.dart';
import 'package:template_a/feat/fav/data/service/get_fav_service.dart';
import 'package:template_a/feat/fav/domain/repo/get_fav_repo.dart';

final getFavRepoImplProvider = Provider<GetFavRepo>(
  (ref) => GetFavRepoImpl(service: ref.read(getFavServiceProvider)),
);

class GetFavRepoImpl implements GetFavRepo {
  final GetFavService service;

  GetFavRepoImpl({required this.service});

  @override
  Future<Either<Exception, GetFavResponseModel>> getFav(
    GetFavRequestModel request,
  ) async {
    return service.getFav(request);
  }
}
