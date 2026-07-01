import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:network/network.dart';
import 'package:template_c/feat/bottom_navigation/sync/data/model/fav_offline_sync_response_model.dart';
import 'package:template_c/feat/bottom_navigation/sync/data/model/fav_sync_offline_request_model.dart';
import 'package:template_c/feat/bottom_navigation/sync/data/repo_impl/sync_fav_offline_repo_impl.dart';
import 'package:template_c/feat/bottom_navigation/sync/domain/repo/sync_fav_offline_repo.dart';

final syncFavOfflineUseCaseProvider = Provider<SyncFavOfflineUseCase>(
  (ref) => SyncFavOfflineUseCase(
    repo: ref.read(syncFavOfflineRepoImplProvider),
  ),
);

class SyncFavOfflineUseCase
    implements
        BaseUseCase<FavOfflineSyncResponseModel, FavSyncOfflineRequestModel> {
  final SyncFavOfflineRepo repo;

  SyncFavOfflineUseCase({required this.repo});

  @override
  Future<Either<Exception, FavOfflineSyncResponseModel>> call(
    FavSyncOfflineRequestModel params,
  ) async {
    return repo.syncFavOffline(params);
  }
}
