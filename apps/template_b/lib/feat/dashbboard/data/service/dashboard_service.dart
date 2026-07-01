import 'dart:convert';
import 'dart:developer' as dev;

import 'package:flutter/services.dart';
import 'package:network/network.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:template_b/feat/dashbboard/model/response/dashboard_config_response_model.dart';

final dashboardServiceProvider = Provider(
  (ref) => DashboardService(apiHelper: ref.read(apiHelperProvider)),
);

class DashboardService {
  ApiHelper apiHelper;

  DashboardService({required this.apiHelper});

  Future<Either<Exception, BaseModel>> getDashBoardConfig(
    BaseModel params,
  ) async {
    try {
      dev.log('[DashboardService] Loading config from local asset');
      final jsonStr = await rootBundle.loadString(
        'assets/config/dashboard.json',
      );
      final data = json.decode(jsonStr) as Map<String, dynamic>;
      dev.log('[DashboardService] Loaded config from asset');
      return Right(DashboardConfigResponseModel().fromJson(data));
    } catch (e) {
      return Left(Exception('Failed to load dashboard config: $e'));
    }
  }
}
