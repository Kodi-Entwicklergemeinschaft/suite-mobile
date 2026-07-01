import 'package:network/network.dart';
import 'package:template_a/feat/parking/data/models/parking_spot_model.dart';

abstract class ParkingRepository {
  Future<Either<Exception, List<ParkingSpotModel>>> getParkingSpaces();
}
