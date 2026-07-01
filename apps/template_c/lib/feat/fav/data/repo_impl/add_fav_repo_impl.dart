import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:template_c/feat/fav/data/model/request_model/add_fav_request_model.dart';
import 'package:template_c/feat/fav/data/model/response_model/add_fav_response_model.dart';
import 'package:template_c/feat/fav/data/service/add_fav_service.dart';
import 'package:template_c/feat/fav/domain/repo/add_fav_repo.dart';

final addFavRepoImplProvider = Provider<AddFavRepo>(
  (ref) => AddFavRepoImpl(addFavService: ref.read(addFavServiceProvider)),
);

class AddFavRepoImpl implements AddFavRepo {
  final AddFavService addFavService;

  AddFavRepoImpl({required this.addFavService});

  @override
  Future<Either<Exception, AddFavResponseModel>> addFav(
    AddFavRequestModel request,
  ) async {
    final result = await addFavService.addFav(request);
    return result.fold((l) => Left(l), (r) => Right(r));
  }
}

