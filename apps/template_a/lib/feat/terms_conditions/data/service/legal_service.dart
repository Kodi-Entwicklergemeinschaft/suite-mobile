import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:network/network.dart';
import 'package:template_a/core/constant/api_endpoints.dart';
import 'package:template_a/core/utils/config_mode.dart';
import '../models/legal_response_model.dart';

final legalServiceProvider = Provider<LegalService>((ref) {
  return LegalService(ref.watch(apiHelperProvider));
});

class LegalService {
  final ApiHelper _apiHelper;

  LegalService(this._apiHelper);

  Future<List<LegalItemModel>> getLegalConfig() async {
    if (!isLiveMode) {
      try {
        final jsonStr = await rootBundle.loadString('assets/config/legal.json');
        final data = json.decode(jsonStr) as Map<String, dynamic>;
        final response = LegalResponseModel().fromJson(data);
        return response.data;
      } catch (_) {
        return [];
      }
    }
    final result = await _apiHelper.getRequest<LegalResponseModel>(
      path: ApiEndpoints.legalConfig,
      create: () => LegalResponseModel(),
    );

    return result.fold(
      (error) => [],
      (response) => response.data,
    );
  }
}
