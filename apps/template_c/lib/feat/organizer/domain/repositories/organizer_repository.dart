import 'package:dartz/dartz.dart';
import 'package:template_c/feat/organizer/data/models/organizer_detail_model.dart';
import 'package:template_c/feat/organizer/data/models/organizer_follow_response_model.dart';
import 'package:template_c/feat/organizer/data/models/organizer_recommendations_response_model.dart';
import 'package:template_c/feat/organizer/data/models/organizer_response_model.dart';

abstract class OrganizerRepository {
  Future<Either<Exception, OrganizerResponseModel>> getOrganizers({
    int page = 1,
    int limit = 20,
  });

  Future<Either<Exception, OrganizerRecommendationsResponseModel>>
      getRecommendations({int limit = 10});

  Future<Either<Exception, OrganizerDetailModel>> getOrganizerDetail(
    String id, {
    int eventsPage = 1,
    int eventsLimit = 10,
  });

  Future<Either<Exception, OrganizerFollowResponseModel>> followOrganizer(
    String userId,
  );

  Future<Either<Exception, OrganizerFollowResponseModel>> unfollowOrganizer(
    String userId,
  );
}
