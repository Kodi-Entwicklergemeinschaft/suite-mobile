import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:template_c/feat/organizer/data/models/organizer_detail_model.dart';
import 'package:template_c/feat/organizer/data/models/organizer_follow_response_model.dart';
import 'package:template_c/feat/organizer/data/models/organizer_recommendations_response_model.dart';
import 'package:template_c/feat/organizer/data/models/organizer_response_model.dart';
import 'package:template_c/feat/organizer/data/service/get_organizer_service.dart';
import 'package:template_c/feat/organizer/domain/repositories/organizer_repository.dart';

final organizerRepositoryProvider = Provider<OrganizerRepository>(
  (ref) => OrganizerRepositoryImpl(
    getOrganizerService: ref.read(getOrganizerServiceProvider),
  ),
);

class OrganizerRepositoryImpl implements OrganizerRepository {
  final GetOrganizerService getOrganizerService;

  OrganizerRepositoryImpl({required this.getOrganizerService});

  @override
  Future<Either<Exception, OrganizerResponseModel>> getOrganizers({
    int page = 1,
    int limit = 20,
  }) async {
    final result = await getOrganizerService.getOrganizers(
      page: page,
      limit: limit,
    );
    return result.fold((l) => Left(l), (r) => Right(r));
  }

  @override
  Future<Either<Exception, OrganizerRecommendationsResponseModel>>
      getRecommendations({int limit = 10}) async {
    final result =
        await getOrganizerService.getRecommendations(limit: limit);
    return result.fold((l) => Left(l), (r) => Right(r));
  }

  @override
  Future<Either<Exception, OrganizerDetailModel>> getOrganizerDetail(
    String id, {
    int eventsPage = 1,
    int eventsLimit = 10,
  }) async {
    final result = await getOrganizerService.getOrganizerDetail(
      id,
      eventsPage: eventsPage,
      eventsLimit: eventsLimit,
    );
    return result.fold((l) => Left(l), (r) => Right(r));
  }

  @override
  Future<Either<Exception, OrganizerFollowResponseModel>> followOrganizer(
    String userId,
  ) async {
    final result = await getOrganizerService.followOrganizer(userId);
    return result.fold((l) => Left(l), (r) => Right(r));
  }

  @override
  Future<Either<Exception, OrganizerFollowResponseModel>> unfollowOrganizer(
    String userId,
  ) async {
    final result = await getOrganizerService.unfollowOrganizer(userId);
    return result.fold((l) => Left(l), (r) => Right(r));
  }
}
