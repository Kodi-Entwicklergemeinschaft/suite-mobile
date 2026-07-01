import 'package:network/network.dart';
import 'package:template_a/feat/home/data/models/home_config.dart';

abstract class HomeRepository {
  Future<Either<Exception, HomeConfigModel>> getHomeConfig();
}
