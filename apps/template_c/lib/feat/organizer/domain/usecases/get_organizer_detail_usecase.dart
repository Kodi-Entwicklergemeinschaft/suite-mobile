import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:network/network.dart';
import 'package:template_c/feat/organizer/data/models/organizer_detail_model.dart';
import 'package:template_c/feat/organizer/data/repositories/organizer_repository_impl.dart';
import 'package:template_c/feat/organizer/domain/repositories/organizer_repository.dart';

final getOrganizerDetailUseCaseProvider = Provider<GetOrganizerDetailUseCase>(
  (ref) => GetOrganizerDetailUseCase(ref.read(organizerRepositoryProvider)),
);

class GetOrganizerDetailUseCase
    implements BaseUseCase<OrganizerDetailModel, String> {
  final OrganizerRepository _repo;

  GetOrganizerDetailUseCase(this._repo);

  @override
  Future<Either<Exception, OrganizerDetailModel>> call(
    String id, {
    int eventsPage = 1,
    int eventsLimit = 10,
  }) =>
      _repo.getOrganizerDetail(id, eventsPage: eventsPage, eventsLimit: eventsLimit);
}
