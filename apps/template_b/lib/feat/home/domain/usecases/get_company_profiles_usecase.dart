import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:network/network.dart';
import 'package:template_b/feat/home/data/models/company_profile_model.dart';
import 'package:template_b/feat/home/data/repositories/home_repository_impl.dart';
import '../repositories/home_repository.dart';

class GetCompanyProfilesParams {
  final int page;
  final int limit;

  GetCompanyProfilesParams({
    this.page = 1,
    this.limit = 10,
  });
}

class GetCompanyProfilesUseCase implements BaseUseCase<List<CompanyProfileModel>, GetCompanyProfilesParams> {
  final HomeRepository repository;

  GetCompanyProfilesUseCase({required this.repository});

  @override
  Future<Either<Exception, List<CompanyProfileModel>>> call(GetCompanyProfilesParams params) {
    return repository.getCompanyProfiles(
      page: params.page,
      limit: params.limit,
    );
  }
}

final getCompanyProfilesUseCaseProvider = Provider((ref) {
  return GetCompanyProfilesUseCase(repository: ref.watch(homeRepositoryProvider));
});
