import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:network/network.dart';
import 'package:template_a/core/constant/api_endpoints.dart';
import 'package:template_a/core/utils/config_mode.dart';
import 'package:template_a/feat/fav/data/model/response_model/get_fav_categories_response_model.dart';

final getFavCategoriesServiceProvider = Provider<GetFavCategoriesService>(
  (ref) => GetFavCategoriesService(apiHelper: ref.watch(apiHelperProvider)),
);

class GetFavCategoriesService {
  final ApiHelper apiHelper;

  GetFavCategoriesService({required this.apiHelper});

  Future<Either<Exception, GetFavCategoriesResponseModel>>
      getFavCategories() async {
    if (!isLiveMode) {
      try {
        final jsonStr = await rootBundle.loadString('assets/config/fav_categories.json');
        final data = json.decode(jsonStr) as Map<String, dynamic>;
        return Right(GetFavCategoriesResponseModel().fromJson(data));
      } catch (e) {
        return Left(Exception('Failed to load local fav categories: $e'));
      }
    }

    final result = await apiHelper.getRequest(
      path: ApiEndpoints.getFavCategories,
      create: () => GetFavCategoriesResponseModel(),
    );
    return result.fold((l) => Left(l), (r) => Right(r));
  }
}
