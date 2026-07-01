import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:network/network.dart';
import 'package:template_c/feat/organizer/data/models/organizer_recommendations_response_model.dart';
import 'package:template_c/feat/organizer/data/repositories/organizer_repository_impl.dart';
import 'package:template_c/feat/organizer/domain/repositories/organizer_repository.dart';

final getOrganizerRecommendationsUseCaseProvider =
    Provider<GetOrganizerRecommendationsUseCase>(
  (ref) => GetOrganizerRecommendationsUseCase(
      ref.read(organizerRepositoryProvider)),
);

class GetOrganizerRecommendationsUseCase
    implements BaseUseCase<OrganizerRecommendationsResponseModel, NoParams> {
  final OrganizerRepository _repo;

  GetOrganizerRecommendationsUseCase(this._repo);

  @override
  Future<Either<Exception, OrganizerRecommendationsResponseModel>> call(
          NoParams _) =>
      _repo.getRecommendations();
}
