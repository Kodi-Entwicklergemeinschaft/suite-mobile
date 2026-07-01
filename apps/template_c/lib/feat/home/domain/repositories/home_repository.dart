import 'package:dartz/dartz.dart';
import 'package:template_c/feat/home/data/models/home_config.dart';

abstract class HomeRepository {
  /// Fetch home configuration from API endpoint
  Future<Either<Exception, HomeConfigModel>> getHomeConfig();
}
