import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:template_a/feat/fav/data/model/request_model/add_fav_request_model.dart';
import 'package:template_a/feat/fav/data/model/response_model/add_fav_response_model.dart';
import 'package:template_a/feat/fav/data/service/add_fav_service.dart';
import 'package:template_a/feat/fav/domain/repo/add_fav_repo.dart';

final addFavRepoImplProvider = Provider<AddFavRepo>(
  (ref) => AddFavRepoImpl(service: ref.read(addFavServiceProvider)),
);

class AddFavRepoImpl implements AddFavRepo {
  final AddFavService service;

  AddFavRepoImpl({required this.service});

  @override
  Future<Either<Exception, AddFavResponseModel>> addFav(
    AddFavRequestModel request,
  ) async {
    return service.addFav(request);
  }
}
