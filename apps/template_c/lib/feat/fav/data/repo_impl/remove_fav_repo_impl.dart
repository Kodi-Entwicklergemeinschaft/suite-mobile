import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:template_c/feat/fav/data/model/request_model/remove_fav_request_model.dart';
import 'package:template_c/feat/fav/data/model/response_model/remove_fav_response_model.dart';
import 'package:template_c/feat/fav/data/service/remove_fav_service.dart';
import 'package:template_c/feat/fav/domain/repo/remove_fav_repo.dart';

final removeFavRepoImplProvider = Provider<RemoveFavRepo>(
  (ref) => RemoveFavRepoImpl(removeFavService: ref.read(removeFavServiceProvider)),
);

class RemoveFavRepoImpl implements RemoveFavRepo {
  final RemoveFavService removeFavService;

  RemoveFavRepoImpl({required this.removeFavService});

  @override
  Future<Either<Exception, RemoveFavResponseModel>> removeFav(
    RemoveFavRequestModel request,
  ) async {
    final result = await removeFavService.removeFav(request);
    return result.fold((l) => Left(l), (r) => Right(r));
  }
}

