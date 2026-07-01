import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:network/network.dart';
import 'package:template_a/core/constant/api_endpoints.dart';
import 'package:template_a/core/utils/config_mode.dart';
import 'package:template_a/feat/fav/data/model/request_model/remove_fav_request_model.dart';
import 'package:template_a/feat/fav/data/model/response_model/remove_fav_response_model.dart';

final removeFavServiceProvider = Provider<RemoveFavService>(
  (ref) => RemoveFavService(apiHelper: ref.watch(apiHelperProvider)),
);

class RemoveFavService {
  final ApiHelper apiHelper;

  RemoveFavService({required this.apiHelper});

  Future<Either<Exception, RemoveFavResponseModel>> removeFav(
    RemoveFavRequestModel request,
  ) async {
    if (!isLiveMode) {
      return Right(RemoveFavResponseModel(success: true, message: 'Removed from favourites.'));
    }
    final endpoint = '${ApiEndpoints.favListingBase}/${request.id}${ApiEndpoints.favSuffix}';
    final result = await apiHelper.deleteRequest(
      path: endpoint,
      create: () => RemoveFavResponseModel(),
    );
    return result.fold((l) => Left(l), (r) => Right(r));
  }
}
