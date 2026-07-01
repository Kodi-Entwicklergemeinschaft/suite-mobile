import 'dart:convert';
import 'dart:developer' as dev;

import 'package:flutter/services.dart';
import 'package:network/network.dart';
import 'package:dartz/dartz.dart';
import 'package:template_b/feat/bottom_navigation/model/request_model/bottom_navigation_config_request_model.dart';
import 'package:template_b/feat/bottom_navigation/model/response_model/bottom_navigation_config_response_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final bottomNavigationServiceProvider = Provider(
  (ref) => BottomNavigationService(apiHelper: ref.read(apiHelperProvider)),
);

class BottomNavigationService {
  ApiHelper apiHelper;

  BottomNavigationService({required this.apiHelper});

  Future<Either<Exception, BottomNavigationConfigResponseModel>>
  getBottomNavigationConfig(BottomNavigationConfigRequestModel params) async {
    try {
      dev.log('[BottomNavService] Loading config from local asset');
      final jsonStr = await rootBundle.loadString(
        'assets/config/bottom_nav.json',
      );
      final data = json.decode(jsonStr) as Map<String, dynamic>;
      dev.log('[BottomNavService] Loaded config from asset');
      return Right(BottomNavigationConfigResponseModel().fromJson(data));
    } catch (e) {
      return Left(Exception('Failed to load bottom nav config: $e'));
    }
  }
}
