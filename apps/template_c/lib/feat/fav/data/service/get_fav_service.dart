import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:network/network.dart';
import 'package:template_c/core/constant/api_endpoints.dart';
import 'package:template_c/feat/fav/data/model/request_model/get_fav_listing_date_request_model.dart';
import 'package:template_c/feat/fav/data/model/request_model/get_fav_request_model.dart';
import 'package:template_c/feat/fav/data/model/response_model/get_fav_categories_response_model.dart';
import 'package:template_c/feat/fav/data/model/response_model/get_fav_listing_date_response_model.dart';
import 'package:template_c/feat/fav/data/model/response_model/get_fav_response_model.dart';
import 'package:template_c/feat/listing/data/models/listing_model.dart';

final getFavServiceProvider = Provider<GetFavService>(
  (ref) => GetFavService(apiHelper: ref.watch(apiHelperProvider)),
);

class GetFavService {
  final ApiHelper apiHelper;

  GetFavService({required this.apiHelper});

  bool get _isLiveMode {
    final base = dotenv.maybeGet('BASE_URL') ?? '';
    return base.isNotEmpty && !base.startsWith('YOUR_');
  }

  Future<List<ListingModel>> _loadDummyFavItems() async {
    final jsonStr = await rootBundle.loadString('assets/config/listings.json');
    final data = json.decode(jsonStr) as Map<String, dynamic>;
    final list = (data['data']?['items'] as List?) ?? [];
    return list
        .take(3)
        .map((e) => ListingModel().fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Either<Exception, GetFavResponseModel>> getFav(
    GetFavRequestModel request,
  ) async {
    if (!_isLiveMode) {
      final items = await _loadDummyFavItems();
      return Right(
        GetFavResponseModel(
          success: true,
          items: items,
          meta: GetFavMetaModel(
            page: 1,
            limit: 20,
            total: items.length,
            totalPages: 1,
            hasNextPage: false,
            hasPreviousPage: false,
          ),
        ),
      );
    }
    final endPoint = ApiEndpoints.getFav;
    final queryParams = request.toJson().map((key, value) {
      if (value is Iterable) return MapEntry(key, value.map((e) => e.toString()).toList());
      return MapEntry(key, value.toString());
    });
    final uri = Uri.parse(endPoint).replace(queryParameters: queryParams);
    final result = await apiHelper.getRequest(path: uri.toString(), create: () => GetFavResponseModel());
    return result.fold((l) => Left(l), (r) => Right(r));
  }

  Future<Either<Exception, GetFavListingDateResponseModel>> getFavListingDate(
    GetFavListingDateRequestModel request,
  ) async {
    if (!_isLiveMode) return Right(GetFavListingDateResponseModel());
    final endPoint = ApiEndpoints.getFavListingDateEndPoint;
    final queryParams = request.toJson().map((key, value) {
      if (value is Iterable) return MapEntry(key, value.map((e) => e.toString()).toList());
      return MapEntry(key, value.toString());
    });
    final uri = Uri.parse(endPoint).replace(queryParameters: queryParams);
    final result = await apiHelper.getRequest(path: uri.toString(), create: () => GetFavListingDateResponseModel());
    return result.fold((l) => Left(l), (r) => Right(r));
  }

  Future<Either<Exception, GetFavCategoriesResponseModel>> getFavCategories() async {
    if (!_isLiveMode) {
      return Right(
        GetFavCategoriesResponseModel(
          success: true,
          data: [
            FavCategoryItemModel(
              id: 'cat-kultur-001',
              slug: 'kultur',
              title: 'Kultur',
              enabled: true,
            ),
          ],
        ),
      );
    }
    final uri = Uri.parse(ApiEndpoints.getFavCategories).replace(queryParameters: {'includeSubcategories': 'true'});
    final result = await apiHelper.getRequest(path: uri.toString(), create: () => GetFavCategoriesResponseModel());
    return result.fold((l) => Left(l), (r) => Right(r));
  }
}
