import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:network/network.dart';
import 'package:template_a/feat/fav/data/model/request_model/get_fav_request_model.dart';
import 'package:template_a/feat/fav/data/model/response_model/get_fav_response_model.dart';
import 'package:template_a/feat/fav/data/repo_impl/get_fav_repo_impl.dart';
import 'package:template_a/feat/fav/domain/repo/get_fav_repo.dart';

final getFavUseCaseProvider = Provider<GetFavUseCase>(
  (ref) => GetFavUseCase(repo: ref.read(getFavRepoImplProvider)),
);

class GetFavUseCase implements BaseUseCase<GetFavResponseModel, GetFavRequestModel> {
  final GetFavRepo repo;

  GetFavUseCase({required this.repo});

  @override
  Future<Either<Exception, GetFavResponseModel>> call(GetFavRequestModel params) {
    return repo.getFav(params);
  }
}
