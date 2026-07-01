import 'package:dartz/dartz.dart';
import 'package:template_c/feat/bottom_navigation/sync/data/model/fav_offline_sync_response_model.dart';
import 'package:template_c/feat/bottom_navigation/sync/data/model/fav_sync_offline_request_model.dart';

abstract class SyncFavOfflineRepo {
  Future<Either<Exception, FavOfflineSyncResponseModel>> syncFavOffline(
    FavSyncOfflineRequestModel request,
  );
}
