import 'dart:convert';
import 'dart:developer' as dev;
import 'package:flutter/services.dart';
import 'package:template_b/feat/services/model/request/get_service_config_request_model.dart';
import 'package:template_b/feat/services/model/response/get_service_config_response_model.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:network/network.dart';

final serviceProvider = Provider(
  (ref) => Service(apiHelper: ref.read(apiHelperProvider)),
);

class Service {
  ApiHelper apiHelper;
  Service({required this.apiHelper});

  Future<Either<Exception, GetServiceConfigResponseModel>> getServiceConfig(
    GetServiceConfigRequestModel params,
  ) async {
    try {
      dev.log('[Service] Loading services config from local asset');
      final jsonStr = await rootBundle.loadString(
        'assets/config/services.json',
      );
      final data = json.decode(jsonStr) as Map<String, dynamic>;
      dev.log('[Service] Loaded services config from asset');
      return Right(GetServiceConfigResponseModel().fromJson(data));
    } catch (e) {
      return Left(Exception('Failed to load services config: $e'));
    }
  }
}
