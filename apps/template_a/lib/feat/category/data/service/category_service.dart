import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:network/network.dart';
import 'package:template_a/core/constant/api_endpoints.dart';
import 'package:template_a/core/utils/config_mode.dart';
import '../models/category_filter_model.dart';

class CategoryService {
  final ApiHelper _apiHelper;

  CategoryService(this._apiHelper);

  Future<Either<Exception, CategoryFilterResponseModel>> getCategoryWithFilters(
    String slugs,
  ) async {
    if (!isLiveMode) {
      try {
        final jsonStr = await rootBundle.loadString('assets/config/categories.json');
        final data = json.decode(jsonStr) as Map<String, dynamic>;
        return Right(CategoryFilterResponseModel().fromJson(data));
      } catch (e) {
        return Left(Exception('Failed to load local categories: $e'));
      }
    }
    return _apiHelper.getRequest<CategoryFilterResponseModel>(
      path: ApiEndpoints.categoriesWithFilters,
      params: {'slugs': slugs},
      create: () => CategoryFilterResponseModel(),
    );
  }
}

final categoryServiceProvider = Provider<CategoryService>(
  (ref) => CategoryService(ref.watch(apiHelperProvider)),
);
