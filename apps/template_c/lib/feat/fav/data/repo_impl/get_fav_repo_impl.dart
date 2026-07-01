import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:template_c/feat/fav/data/model/request_model/get_fav_listing_date_request_model.dart';
import 'package:template_c/feat/fav/data/model/request_model/get_fav_request_model.dart';
import 'package:template_c/feat/fav/data/model/response_model/get_fav_categories_response_model.dart';
import 'package:template_c/feat/fav/data/model/response_model/get_fav_listing_date_response_model.dart';
import 'package:template_c/feat/fav/data/model/response_model/get_fav_response_model.dart';
import 'package:template_c/feat/fav/data/service/get_fav_service.dart';
import 'package:template_c/feat/fav/domain/repo/get_fav_repo.dart';

final getFavRepoImplProvider = Provider<GetFavRepo>(
  (ref) => GetFavRepoImpl(getFavService: ref.read(getFavServiceProvider)),
);

class GetFavRepoImpl implements GetFavRepo {
  final GetFavService getFavService;

  GetFavRepoImpl({required this.getFavService});

  @override
  Future<Either<Exception, GetFavResponseModel>> getFav(
    GetFavRequestModel request,
  ) async {
    final result = await getFavService.getFav(request);
    return result.fold((l) => Left(l), (r) => Right(r));
  }

  @override
  Future<Either<Exception, GetFavListingDateResponseModel>> getFavListingDate(
    GetFavListingDateRequestModel request,
  ) async {
    final result = await getFavService.getFavListingDate(request);
    return result.fold((l) => Left(l), (r) => Right(r));
  }

  @override
  Future<Either<Exception, GetFavCategoriesResponseModel>>
  getFavCategories() async {
    final result = await getFavService.getFavCategories();
    return result.fold((l) => Left(l), (r) => Right(r));
  }
}
