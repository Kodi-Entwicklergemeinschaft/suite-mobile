import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:network/network.dart';
import 'package:template_c/feat/fav/data/model/request_model/get_fav_listing_date_request_model.dart';
import 'package:template_c/feat/fav/data/model/request_model/get_fav_request_model.dart';
import 'package:template_c/feat/fav/data/model/response_model/get_fav_categories_response_model.dart';
import 'package:template_c/feat/fav/data/model/response_model/get_fav_listing_date_response_model.dart';
import 'package:template_c/feat/fav/data/model/response_model/get_fav_response_model.dart';
import 'package:template_c/feat/fav/data/repo_impl/get_fav_repo_impl.dart';
import 'package:template_c/feat/fav/domain/repo/get_fav_repo.dart';

final getFavUseCaseProvider = Provider<GetFavUseCase>(
  (ref) => GetFavUseCase(repo: ref.read(getFavRepoImplProvider)),
);

class GetFavUseCase
    implements BaseUseCase<GetFavResponseModel, GetFavRequestModel> {
  final GetFavRepo repo;

  GetFavUseCase({required this.repo});

  @override
  Future<Either<Exception, GetFavResponseModel>> call(
    GetFavRequestModel params,
  ) async {
    return repo.getFav(params);
  }

  Future<Either<Exception, GetFavListingDateResponseModel>> getFavListingDate(
    GetFavListingDateRequestModel request,
  ) async {
    return repo.getFavListingDate(request);
  }

  Future<Either<Exception, GetFavCategoriesResponseModel>>
  getFavCategories() async {
    return repo.getFavCategories();
  }
}
