import 'dart:developer' as dev;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:network/network.dart';
import 'package:template_a/core/constant/api_endpoints.dart';
import 'package:template_a/core/utils/config_mode.dart';
import '../models/parking_spot_model.dart';
import '../models/parking_spaces_response_model.dart';

class ParkingService {
  final ApiHelper _apiHelper;

  ParkingService(this._apiHelper);

  Future<Either<Exception, List<ParkingSpotModel>>> getParkingSpaces() async {
    if (!isLiveMode) {
      return const Right([]);
    }

    try {
      dev.log('[ParkingService] Fetching parking spaces from API');

      final result =
          await _apiHelper.getRequest<ParkingSpacesResponseModel>(
        path: ApiEndpoints.parkingSpaces,
        create: () => ParkingSpacesResponseModel(),
      );

      return result.fold(
        (error) {
          dev.log('[ParkingService] API error: $error', error: error);
          return Left(Exception('Failed to load parking spaces: $error'));
        },
        (response) {
          if (!response.success) {
            dev.log(
              '[ParkingService] API returned success=false: ${response.message}',
            );
            return Left(
              Exception(
                'API error: ${response.message ?? "Unknown error"}',
              ),
            );
          }

          dev.log(
            '[ParkingService] Successfully loaded ${response.spots.length} parking spaces',
          );
          return Right(response.spots);
        },
      );
    } catch (e, stackTrace) {
      dev.log(
        '[ParkingService] Unexpected error: $e',
        error: e,
        stackTrace: stackTrace,
      );
      return Left(Exception('Failed to load parking spaces: $e'));
    }
  }
}

final parkingServiceProvider = Provider<ParkingService>((ref) {
  final apiHelper = ref.watch(apiHelperProvider);
  return ParkingService(apiHelper);
});
