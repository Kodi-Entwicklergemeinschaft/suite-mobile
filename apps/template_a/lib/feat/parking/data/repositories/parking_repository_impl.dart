import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:network/network.dart';
import 'package:template_a/feat/parking/data/models/parking_spot_model.dart';
import 'package:template_a/feat/parking/data/service/parking_service.dart';
import 'package:template_a/feat/parking/domain/repositories/parking_repository.dart';

class ParkingRepositoryImpl implements ParkingRepository {
  final ParkingService _parkingService;

  ParkingRepositoryImpl(this._parkingService);

  @override
  Future<Either<Exception, List<ParkingSpotModel>>> getParkingSpaces() async {
    try {
      final result = await _parkingService.getParkingSpaces();
      return result.fold(
        (error) => Left(error),
        (spots) => Right(spots),
      );
    } catch (e) {
      return Left(Exception('Repository error: $e'));
    }
  }
}

final parkingRepositoryProvider = Provider<ParkingRepository>((ref) {
  final parkingService = ref.watch(parkingServiceProvider);
  return ParkingRepositoryImpl(parkingService);
});
