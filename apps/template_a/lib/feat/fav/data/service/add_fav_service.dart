import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:network/network.dart';
import 'package:template_a/core/constant/api_endpoints.dart';
import 'package:template_a/core/utils/config_mode.dart';
import 'package:template_a/feat/fav/data/model/request_model/add_fav_request_model.dart';
import 'package:template_a/feat/fav/data/model/response_model/add_fav_response_model.dart';

final addFavServiceProvider = Provider<AddFavService>(
  (ref) => AddFavService(apiHelper: ref.watch(apiHelperProvider)),
);

class AddFavService {
  final ApiHelper apiHelper;

  AddFavService({required this.apiHelper});

  Future<Either<Exception, AddFavResponseModel>> addFav(
    AddFavRequestModel request,
  ) async {
    if (!isLiveMode) {
      return Right(AddFavResponseModel(success: true, message: 'Added to favourites.'));
    }
    final endpoint = '${ApiEndpoints.favListingBase}/${request.id}${ApiEndpoints.favSuffix}';
    final result = await apiHelper.postRequest(
      path: endpoint,
      create: () => AddFavResponseModel(),
    );
    return result.fold((l) => Left(l), (r) => Right(r));
  }
}
