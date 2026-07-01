import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:network/network.dart';
import 'package:template_a/core/constant/api_endpoints.dart';
import 'package:template_a/core/utils/config_mode.dart';
import '../models/get_service_config_request_model.dart';
import '../models/get_service_config_response_model.dart';

final serviceProvider = Provider(
  (ref) => Service(apiHelper: ref.read(apiHelperProvider)),
);

class Service {
  final ApiHelper apiHelper;
  Service({required this.apiHelper});

  Future<Either<Exception, GetServiceConfigResponseModel>> getServiceConfig(
    GetServiceConfigRequestModel params,
  ) async {
    if (!isLiveMode) {
      try {
        final jsonStr = await rootBundle.loadString('assets/config/services.json');
        final data = json.decode(jsonStr) as Map<String, dynamic>;
        return Right(GetServiceConfigResponseModel().fromJson(data));
      } catch (e) {
        return Left(Exception('Failed to load local services config: $e'));
      }
    }

    final uri = Uri.parse(ApiEndpoints.serviceConfig).replace(
      queryParameters: params.toJson(),
    );

    final result = await apiHelper.getRequest(
      path: uri.toString(),
      create: () => GetServiceConfigResponseModel(),
    );

    return result.fold((l) => Left(l), (r) => Right(r));
  }
}
