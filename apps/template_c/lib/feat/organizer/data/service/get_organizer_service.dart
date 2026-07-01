import 'package:dartz/dartz.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:network/network.dart';
import 'package:template_c/core/constant/api_endpoints.dart';
import 'package:template_c/feat/organizer/data/models/organizer_detail_model.dart';
import 'package:template_c/feat/organizer/data/models/organizer_follow_response_model.dart';
import 'package:template_c/feat/organizer/data/models/organizer_recommendations_response_model.dart';
import 'package:template_c/feat/organizer/data/models/organizer_response_model.dart';

final getOrganizerServiceProvider = Provider<GetOrganizerService>(
  (ref) => GetOrganizerService(apiHelper: ref.watch(apiHelperProvider)),
);

class GetOrganizerService {
  final ApiHelper apiHelper;

  GetOrganizerService({required this.apiHelper});

  bool get _isLiveMode {
    final base = dotenv.maybeGet('BASE_URL') ?? '';
    return base.isNotEmpty && !base.startsWith('YOUR_');
  }

  Future<Either<Exception, OrganizerResponseModel>> getOrganizers({
    int page = 1,
    int limit = 20,
  }) async {
    if (!_isLiveMode) return Right(OrganizerResponseModel());
    final result = await apiHelper.getRequest<OrganizerResponseModel>(
      path: ApiEndpoints.organizers,
      params: {'page': page, 'limit': limit},
      create: () => OrganizerResponseModel(),
    );
    return result.fold((l) => Left(l), (r) => Right(r));
  }

  Future<Either<Exception, OrganizerRecommendationsResponseModel>>
      getRecommendations({int limit = 10}) async {
    if (!_isLiveMode) return Right(OrganizerRecommendationsResponseModel());
    final result = await apiHelper.getRequest<OrganizerRecommendationsResponseModel>(
      path: ApiEndpoints.organizerRecommendations,
      params: {'limit': limit},
      create: () => OrganizerRecommendationsResponseModel(),
    );
    return result.fold((l) => Left(l), (r) => Right(r));
  }

  Future<Either<Exception, OrganizerDetailModel>> getOrganizerDetail(
    String id, {
    int eventsPage = 1,
    int eventsLimit = 10,
  }) async {
    if (!_isLiveMode) return Right(OrganizerDetailModel());
    final result = await apiHelper.getRequest<OrganizerDetailModel>(
      path: '${ApiEndpoints.organizerDetailBase}/$id',
      params: {'page': eventsPage, 'limit': eventsLimit},
      create: () => OrganizerDetailModel(),
    );
    return result.fold((l) => Left(l), (r) => Right(r));
  }

  Future<Either<Exception, OrganizerFollowResponseModel>> followOrganizer(
    String userId,
  ) async {
    if (!_isLiveMode) return Right(OrganizerFollowResponseModel(success: true));
    try {
      final response = await apiHelper.dio.post(
        '${ApiEndpoints.organizerFollowBase}/$userId',
      );
      final data = response.data;
      final model = OrganizerFollowResponseModel().fromJson(
        data is Map<String, dynamic> ? data : {'success': true},
      );
      return Right(model);
    } on ConflictException {
      return Right(OrganizerFollowResponseModel(success: true));
    } catch (e) {
      return Left(ApiError(error: e.toString()));
    }
  }

  Future<Either<Exception, OrganizerFollowResponseModel>> unfollowOrganizer(
    String userId,
  ) async {
    if (!_isLiveMode) return Right(OrganizerFollowResponseModel(success: true));
    final result = await apiHelper.deleteRequest(
      path: '${ApiEndpoints.organizerFollowBase}/$userId',
      create: () => OrganizerFollowResponseModel(),
    );
    return result.fold((l) => Left(l), (r) => Right(r));
  }
}
