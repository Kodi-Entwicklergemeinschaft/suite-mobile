import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:network/network.dart';
import 'package:template_c/feat/fav/data/model/request_model/add_fav_request_model.dart';
import 'package:template_c/feat/fav/data/model/response_model/add_fav_response_model.dart';
import 'package:template_c/feat/fav/data/repo_impl/add_fav_repo_impl.dart';
import 'package:template_c/feat/fav/domain/repo/add_fav_repo.dart';

final addFavUseCaseProvider = Provider<AddFavUseCase>(
  (ref) => AddFavUseCase(repo: ref.read(addFavRepoImplProvider)),
);

class AddFavUseCase
    implements BaseUseCase<AddFavResponseModel, AddFavRequestModel> {
  final AddFavRepo repo;

  AddFavUseCase({required this.repo});

  @override
  Future<Either<Exception, AddFavResponseModel>> call(
    AddFavRequestModel params,
  ) async {
    return repo.addFav(params);
  }
}

