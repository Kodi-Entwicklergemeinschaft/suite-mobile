import 'dart:convert';
import 'dart:developer' as dev;

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:network/network.dart';
import 'package:template_a/core/constant/api_endpoints.dart';
import 'package:template_a/core/utils/config_mode.dart';
import '../models/home_config.dart';
import '../models/home_config_response_model.dart';

class HomeService {
  final ApiHelper _apiHelper;

  HomeService(this._apiHelper);

  Future<Either<Exception, HomeConfigModel>> getHomeConfig() async {
    if (!isLiveMode) {
      try {
        final jsonStr = await rootBundle.loadString('assets/config/homepage.json');
        final data = json.decode(jsonStr) as Map<String, dynamic>;
        final response = HomeConfigResponseModel().fromJson(data);
        if (response.homeConfig == null) {
          return Left(Exception('Invalid local home config'));
        }
        return Right(response.homeConfig!);
      } catch (e) {
        return Left(Exception('Failed to load local home config: $e'));
      }
    }

    try {
      dev.log('[HomeService] Fetching home config from API');

      final result = await _apiHelper.getRequest<HomeConfigResponseModel>(
        path: ApiEndpoints.homeConfig,
        create: () => HomeConfigResponseModel(),
      );

      return result.fold(
        (error) {
          dev.log('[HomeService] API error: $error', error: error);
          return Left(Exception('Failed to load home config: $error'));
        },
        (response) {
          if (!response.success) {
            dev.log(
              '[HomeService] API returned success=false: ${response.message}',
            );
            return Left(
              Exception(
                'API error: ${response.message ?? "Unknown error"}',
              ),
            );
          }

          if (response.homeConfig == null) {
            dev.log('[HomeService] API returned null home config');
            return Left(Exception('Invalid response: home config is null'));
          }

          dev.log(
            '[HomeService] Successfully loaded home config with ${response.homeConfig!.components.length} components',
          );
          return Right(response.homeConfig!);
        },
      );
    } catch (e, stackTrace) {
      dev.log(
        '[HomeService] Unexpected error: $e',
        error: e,
        stackTrace: stackTrace,
      );
      return Left(Exception('Failed to load home config: $e'));
    }
  }
}

final homeServiceProvider = Provider<HomeService>((ref) {
  final apiHelper = ref.watch(apiHelperProvider);
  return HomeService(apiHelper);
});
