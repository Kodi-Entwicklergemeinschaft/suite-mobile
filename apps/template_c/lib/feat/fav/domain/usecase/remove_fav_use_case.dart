import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:network/network.dart';
import 'package:template_c/feat/fav/data/model/request_model/remove_fav_request_model.dart';
import 'package:template_c/feat/fav/data/model/response_model/remove_fav_response_model.dart';
import 'package:template_c/feat/fav/data/repo_impl/remove_fav_repo_impl.dart';
import 'package:template_c/feat/fav/domain/repo/remove_fav_repo.dart';

final removeFavUseCaseProvider = Provider<RemoveFavUseCase>(
  (ref) => RemoveFavUseCase(repo: ref.read(removeFavRepoImplProvider)),
);

class RemoveFavUseCase
    implements BaseUseCase<RemoveFavResponseModel, RemoveFavRequestModel> {
  final RemoveFavRepo repo;

  RemoveFavUseCase({required this.repo});

  @override
  Future<Either<Exception, RemoveFavResponseModel>> call(
    RemoveFavRequestModel params,
  ) async {
    return repo.removeFav(params);
  }
}

