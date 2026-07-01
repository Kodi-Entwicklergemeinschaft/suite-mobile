import 'dart:convert';
import 'dart:developer' as dev;
import 'package:dartz/dartz.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:network/network.dart';
import 'package:template_b/feat/legal/model/request/legal_request_model.dart';
import 'package:template_b/feat/legal/model/response/legal_response_model.dart';

final legalServiceProvider = Provider<LegalService>((ref) {
  final apiHelper = ref.read(apiHelperProvider);
  return LegalService(apiHelper: apiHelper);
});

class LegalService {
  final ApiHelper _apiHelper;

  LegalService({required ApiHelper apiHelper}) : _apiHelper = apiHelper;

  Future<Either<Exception, LegalResponseModel>> getLegalConfig(
    LegalRequestModel params,
  ) async {
    try {
      dev.log('[LegalService] Loading legal config from local asset');
      final jsonStr = await rootBundle.loadString('assets/config/legal.json');
      final data = json.decode(jsonStr) as Map<String, dynamic>;
      dev.log('[LegalService] Loaded legal config from asset');
      return Right(LegalResponseModel().fromJson(data));
    } catch (e) {
      return Left(Exception('Failed to load legal config: $e'));
    }
  }
}
