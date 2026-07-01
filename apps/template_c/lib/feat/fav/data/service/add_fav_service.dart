import 'package:dartz/dartz.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:network/network.dart';
import 'package:template_c/core/constant/api_endpoints.dart';
import 'package:template_c/feat/fav/data/model/request_model/add_fav_request_model.dart';
import 'package:template_c/feat/fav/data/model/response_model/add_fav_response_model.dart';

final addFavServiceProvider = Provider<AddFavService>(
  (ref) => AddFavService(apiHelper: ref.watch(apiHelperProvider)),
);

class AddFavService {
  final ApiHelper apiHelper;

  AddFavService({required this.apiHelper});

  bool get _isLiveMode {
    final base = dotenv.maybeGet('BASE_URL') ?? '';
    return base.isNotEmpty && !base.startsWith('YOUR_');
  }

  Future<Either<Exception, AddFavResponseModel>> addFav(
    AddFavRequestModel request,
  ) async {
    if (!_isLiveMode) return Right(AddFavResponseModel());
    final endpoint = '${ApiEndpoints.addFavEndPoint}/${request.id}${ApiEndpoints.fav}';
    final result = await apiHelper.postRequest(path: endpoint, create: () => AddFavResponseModel());
    return result.fold((l) => Left(l), (r) => Right(r));
  }
}
