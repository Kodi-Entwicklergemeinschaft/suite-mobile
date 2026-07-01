import 'package:dartz/dartz.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:network/network.dart';
import 'package:template_c/core/constant/api_endpoints.dart';
import 'package:template_c/feat/bottom_navigation/sync/data/model/fav_offline_sync_response_model.dart';
import 'package:template_c/feat/bottom_navigation/sync/data/model/fav_sync_offline_request_model.dart';

final syncFavOfflineServiceProvider = Provider<SyncFavOfflineService>(
  (ref) => SyncFavOfflineService(apiHelper: ref.watch(apiHelperProvider)),
);

class SyncFavOfflineService {
  final ApiHelper apiHelper;

  SyncFavOfflineService({required this.apiHelper});

  bool get _isLiveMode {
    final base = dotenv.maybeGet('BASE_URL') ?? '';
    return base.isNotEmpty && !base.startsWith('YOUR_');
  }

  Future<Either<Exception, FavOfflineSyncResponseModel>> syncFavOffline(
    FavSyncOfflineRequestModel request,
  ) async {
    if (!_isLiveMode) return Right(FavOfflineSyncResponseModel());
    final result = await apiHelper.postRequest(
      path: ApiEndpoints.syncOffline,
      body: request.toJson(),
      create: () => FavOfflineSyncResponseModel(),
    );
    return result.fold((l) => Left(l), (r) => Right(r));
  }
}
