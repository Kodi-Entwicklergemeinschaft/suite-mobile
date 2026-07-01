import 'package:dartz/dartz.dart';
import 'package:network/network.dart';

abstract class DashboardRepo {
  Future<Either<Exception, BaseModel>> getDashboardConfig(BaseModel params);
}
