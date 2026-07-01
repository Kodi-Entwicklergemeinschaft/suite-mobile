import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:template_a/feat/fav/data/model/request_model/remove_fav_request_model.dart';
import 'package:template_a/feat/fav/data/model/response_model/remove_fav_response_model.dart';
import 'package:template_a/feat/fav/data/service/remove_fav_service.dart';
import 'package:template_a/feat/fav/domain/repo/remove_fav_repo.dart';

final removeFavRepoImplProvider = Provider<RemoveFavRepo>(
  (ref) => RemoveFavRepoImpl(service: ref.read(removeFavServiceProvider)),
);

class RemoveFavRepoImpl implements RemoveFavRepo {
  final RemoveFavService service;

  RemoveFavRepoImpl({required this.service});

  @override
  Future<Either<Exception, RemoveFavResponseModel>> removeFav(
    RemoveFavRequestModel request,
  ) async {
    return service.removeFav(request);
  }
}
