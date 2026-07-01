import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/model/locality_model.dart';
import '../../data/repo_impl/locality_repo_impl.dart';
import '../repo/locality_repo.dart';

final fetchLocalitiesUsecaseProvider = Provider<FetchLocalitiesUsecase>(
  (ref) => FetchLocalitiesUsecase(repo: ref.watch(localityRepoImplProvider)),
);

class FetchLocalitiesUsecase {
  final LocalityRepo repo;

  FetchLocalitiesUsecase({required this.repo});

  Future<List<LocalityModel>> call(String serviceSlug) =>
      repo.fetchLocalities(serviceSlug);
}
