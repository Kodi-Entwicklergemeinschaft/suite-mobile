import 'dart:convert';
import 'dart:developer' as dev;

import 'package:dartz/dartz.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/home_config.dart';
import '../models/home_config_response_model.dart';

class HomeService {
  Future<Either<Exception, HomeConfigModel>> getHomeConfig() async {
    try {
      dev.log('[HomeService] Loading home config from local asset');
      final jsonStr = await rootBundle.loadString(
        'assets/config/homepage.json',
      );
      final data = json.decode(jsonStr) as Map<String, dynamic>;
      final response = HomeConfigResponseModel().fromJson(data);

      if (!response.success) {
        return Left(Exception('Asset error: ${response.message ?? "Unknown"}'));
      }
      if (response.homeConfig == null) {
        return Left(Exception('Invalid asset: home config is null'));
      }

      dev.log(
        '[HomeService] Loaded home config with ${response.homeConfig!.components.length} components',
      );
      return Right(response.homeConfig!);
    } catch (e, stackTrace) {
      dev.log('[HomeService] Error: $e', error: e, stackTrace: stackTrace);
      return Left(Exception('Failed to load home config: $e'));
    }
  }
}

final homeServiceProvider = Provider<HomeService>((ref) {
  return HomeService();
});
