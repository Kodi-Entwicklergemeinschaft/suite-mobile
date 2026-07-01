import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:network/network.dart';
import 'package:template_a/feat/parking/data/models/parking_spot_model.dart';
import 'package:template_a/feat/parking/data/repositories/parking_repository_impl.dart';
import '../repositories/parking_repository.dart';

class GetParkingSpacesUseCase
    implements BaseUseCase<List<ParkingSpotModel>, NoParams> {
  final ParkingRepository repository;

  GetParkingSpacesUseCase({required this.repository});

  @override
  Future<Either<Exception, List<ParkingSpotModel>>> call(NoParams params) {
    return repository.getParkingSpaces();
  }
}

final getParkingSpacesUseCaseProvider =
    Provider<GetParkingSpacesUseCase>((ref) {
  return GetParkingSpacesUseCase(
    repository: ref.watch(parkingRepositoryProvider),
  );
});
