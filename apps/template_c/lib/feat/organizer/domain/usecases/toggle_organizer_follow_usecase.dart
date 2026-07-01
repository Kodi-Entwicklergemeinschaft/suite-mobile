import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:template_c/feat/organizer/data/models/organizer_follow_response_model.dart';
import 'package:template_c/feat/organizer/data/repositories/organizer_repository_impl.dart';
import 'package:template_c/feat/organizer/domain/repositories/organizer_repository.dart';

final toggleOrganizerFollowUseCaseProvider =
    Provider<ToggleOrganizerFollowUseCase>(
  (ref) => ToggleOrganizerFollowUseCase(ref.read(organizerRepositoryProvider)),
);

class ToggleOrganizerFollowUseCase {
  final OrganizerRepository _repo;

  ToggleOrganizerFollowUseCase(this._repo);

  Future<Either<Exception, OrganizerFollowResponseModel>> call(
    String userId, {
    required bool subscribe,
  }) =>
      subscribe
          ? _repo.followOrganizer(userId)
          : _repo.unfollowOrganizer(userId);
}
