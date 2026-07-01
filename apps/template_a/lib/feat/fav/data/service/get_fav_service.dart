import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:network/network.dart';
import 'package:template_a/core/constant/api_endpoints.dart';
import 'package:template_a/core/utils/config_mode.dart';
import 'package:template_a/feat/fav/data/model/request_model/get_fav_request_model.dart';
import 'package:template_a/feat/fav/data/model/response_model/get_fav_response_model.dart';

final getFavServiceProvider = Provider<GetFavService>(
  (ref) => GetFavService(apiHelper: ref.watch(apiHelperProvider)),
);

class GetFavService {
  final ApiHelper apiHelper;

  GetFavService({required this.apiHelper});

  Future<Either<Exception, GetFavResponseModel>> getFav(
    GetFavRequestModel request,
  ) async {
    if (!isLiveMode) {
      try {
        final jsonStr = await rootBundle.loadString('assets/config/favourites.json');
        final data = json.decode(jsonStr) as Map<String, dynamic>;
        return Right(GetFavResponseModel().fromJson(data));
      } catch (e) {
        return Left(Exception('Failed to load local favourites: $e'));
      }
    }

    final queryParams = request.toJson().map(
          (key, value) => MapEntry(key, value.toString()),
        );
    final uri = Uri.parse(ApiEndpoints.getFavListings)
        .replace(queryParameters: queryParams);

    final result = await apiHelper.getRequest(
      path: uri.toString(),
      create: () => GetFavResponseModel(),
    );
    return result.fold((l) => Left(l), (r) => Right(r));
  }
}
