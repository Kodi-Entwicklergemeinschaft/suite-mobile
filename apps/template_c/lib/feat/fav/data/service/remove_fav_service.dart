import 'package:dartz/dartz.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:network/network.dart';
import 'package:template_c/core/constant/api_endpoints.dart';
import 'package:template_c/feat/fav/data/model/request_model/remove_fav_request_model.dart';
import 'package:template_c/feat/fav/data/model/response_model/remove_fav_response_model.dart';

final removeFavServiceProvider = Provider<RemoveFavService>(
  (ref) => RemoveFavService(apiHelper: ref.watch(apiHelperProvider)),
);

class RemoveFavService {
  final ApiHelper apiHelper;

  RemoveFavService({required this.apiHelper});

  bool get _isLiveMode {
    final base = dotenv.maybeGet('BASE_URL') ?? '';
    return base.isNotEmpty && !base.startsWith('YOUR_');
  }

  Future<Either<Exception, RemoveFavResponseModel>> removeFav(
    RemoveFavRequestModel request,
  ) async {
    if (!_isLiveMode) return Right(RemoveFavResponseModel());
    final endpoint = '${ApiEndpoints.addFavEndPoint}/${request.id}${ApiEndpoints.fav}';
    final result = await apiHelper.deleteRequest(path: endpoint, create: () => RemoveFavResponseModel());
    return result.fold((l) => Left(l), (r) => Right(r));
  }
}
