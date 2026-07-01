import 'package:dartz/dartz.dart';
import 'package:network/network.dart';

abstract class BottomNavigationRepo {
  Future<Either<Exception, BaseModel>> getBottomNavigationConfig({required BaseModel params});
}
