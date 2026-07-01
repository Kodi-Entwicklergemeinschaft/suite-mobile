import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:network/network.dart';
import 'package:template_c/core/constant/api_endpoints.dart';
import 'package:template_c/feat/location_onboarding/data/model/request_model/location_preference_request_model.dart';
import 'package:template_c/feat/location_onboarding/data/model/request_model/location_request_model.dart';
import 'package:template_c/feat/location_onboarding/data/model/response_model/location_preference_response_model.dart';
import 'package:template_c/feat/location_onboarding/data/model/response_model/location_response_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final locationServiceProvider = Provider(
  (ref) => LocationService(
    dio: Dio(
      BaseOptions(
        baseUrl: 'https://nominatim.openstreetmap.org',
        headers: {'User-Agent': 'SuiteMobile/1.0'},
      ),
    ),
    apiHelper: ref.watch(apiHelperProvider),
  ),
);

class LocationService {
  final Dio dio;
  final ApiHelper _apiHelper;

  LocationService({required this.dio, required ApiHelper apiHelper})
      : _apiHelper = apiHelper;

  Future<Either<Exception, LocationResponseModel>> getLocation(
    LocationRequestModel params,
  ) async {
    if (!_isLiveMode) return Right([]);
    try {
      final res = await dio.get('/search?format=json&q=${params.name}');
      return Right(locationResponseModelFromJsonList(res.data));
    } catch (error) {
      return Left(Exception(error));
    }
  }

  bool get _isLiveMode {
    final base = dotenv.maybeGet('BASE_URL') ?? '';
    return base.isNotEmpty && !base.startsWith('YOUR_');
  }

  Future<Either<Exception, LocationPreferenceResponseModel>>
      updateLocationPreference(LocationPreferenceRequestModel request) async {
    if (!_isLiveMode) return Right(LocationPreferenceResponseModel());
    return _apiHelper.putRequest<LocationPreferenceResponseModel>(
      path: ApiEndpoints.userLocationPreference,
      body: request.toJson(),
      create: () => LocationPreferenceResponseModel(),
    );
  }
}
