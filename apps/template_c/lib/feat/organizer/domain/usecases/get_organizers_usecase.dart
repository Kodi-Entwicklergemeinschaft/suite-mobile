import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:network/network.dart';
import 'package:template_c/feat/organizer/data/models/organizer_response_model.dart';
import 'package:template_c/feat/organizer/data/repositories/organizer_repository_impl.dart';
import 'package:template_c/feat/organizer/domain/repositories/organizer_repository.dart';

final getOrganizersUseCaseProvider = Provider<GetOrganizersUseCase>(
  (ref) => GetOrganizersUseCase(ref.read(organizerRepositoryProvider)),
);

class GetOrganizersUseCase
    implements BaseUseCase<OrganizerResponseModel, NoParams> {
  final OrganizerRepository _repo;

  GetOrganizersUseCase(this._repo);

  @override
  Future<Either<Exception, OrganizerResponseModel>> call(
    NoParams _, {
    int page = 1,
    int limit = 20,
  }) =>
      _repo.getOrganizers(page: page, limit: limit);
}
