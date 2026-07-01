import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:template_c/feat/bottom_navigation/sync/data/model/fav_offline_sync_response_model.dart';
import 'package:template_c/feat/bottom_navigation/sync/data/model/fav_sync_offline_request_model.dart';
import 'package:template_c/feat/bottom_navigation/sync/data/service/sync_fav_offline_service.dart';
import 'package:template_c/feat/bottom_navigation/sync/domain/repo/sync_fav_offline_repo.dart';

final syncFavOfflineRepoImplProvider = Provider<SyncFavOfflineRepo>(
  (ref) => SyncFavOfflineRepoImpl(
    syncFavOfflineService: ref.read(syncFavOfflineServiceProvider),
  ),
);

class SyncFavOfflineRepoImpl implements SyncFavOfflineRepo {
  final SyncFavOfflineService syncFavOfflineService;

  SyncFavOfflineRepoImpl({required this.syncFavOfflineService});

  @override
  Future<Either<Exception, FavOfflineSyncResponseModel>> syncFavOffline(
    FavSyncOfflineRequestModel request,
  ) async {
    final result = await syncFavOfflineService.syncFavOffline(request);
    return result.fold((l) => Left(l), (r) => Right(r));
  }
}
