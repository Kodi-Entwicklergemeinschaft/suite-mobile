import 'package:network/network.dart';

abstract class UploadAdRepo {
  Future<Either<Exception, BaseModel>> getUploadAdConfig(BaseModel params);

  Future<Either<Exception, BaseModel>> uploadAd(BaseModel params);
}
