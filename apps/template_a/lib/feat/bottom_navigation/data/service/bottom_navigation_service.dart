import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:network/network.dart';
import 'package:template_a/core/constant/api_endpoints.dart';
import 'package:template_a/core/utils/config_mode.dart';
import 'package:template_a/feat/bottom_navigation/data/model/response/bottom_navigation_response_model.dart';

final bottomNavigationServiceProvider = Provider<BottomNavigationService>((ref) {
  final apiHelper = ref.watch(apiHelperProvider);
  return BottomNavigationService(apiHelper);
});

class BottomNavigationService {
  final ApiHelper _apiHelper;

  BottomNavigationService(this._apiHelper);

  Future<Either<Exception, BaseModel>> getBottomNavigationConfig({
    required BaseModel params,
  }) async {
    if (!isLiveMode) {
      final jsonStr = await rootBundle.loadString('assets/config/bottom_config.json');
      final data = json.decode(jsonStr) as Map<String, dynamic>;
      return Right(BottomNavigationResponseModel().fromJson(data));
    }
    return _apiHelper.getRequest<BottomNavigationResponseModel>(
      path: ApiEndpoints.bottomNavConfig,
      create: () => BottomNavigationResponseModel(),
    );
  }
}
