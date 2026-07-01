import 'dart:convert';
import 'dart:developer' as dev;

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dartz/dartz.dart';
import 'package:network/network.dart';
import 'package:template_c/feat/bottom_navigation/data/model/response/bottom_navigation_response_model.dart';

final bottomNavigationServiceProvider = Provider(
  (ref) => BottomNavigationService(),
);

class BottomNavigationService {
  Future<Either<Exception, BaseModel>> getBottomNavigationConfig({
    required BaseModel params,
  }) async {
    try {
      dev.log('[BottomNavService] Loading config from local asset');
      final jsonStr = await rootBundle.loadString(
        'assets/config/bottom_nav.json',
      );
      final data = json.decode(jsonStr) as Map<String, dynamic>;
      dev.log('[BottomNavService] Loaded config from asset');
      return Right(BottomNavigationResponseModel().fromJson(data));
    } catch (e) {
      return Left(Exception('Failed to load bottom nav config: $e'));
    }
  }
}
