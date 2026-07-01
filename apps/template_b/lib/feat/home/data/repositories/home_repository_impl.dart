import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:template_b/feat/home/data/models/home_config.dart';
import 'package:template_b/feat/home/data/models/get_localities_filter_model.dart';
import 'package:template_b/feat/home/data/models/update_locality_selection_model.dart';
import 'package:template_b/feat/home/data/models/update_locality_selection_response_model.dart';
import 'package:template_b/feat/home/data/models/company_profile_model.dart';
import 'package:template_b/feat/home/service/home_service.dart';
import '../../domain/repositories/home_repository.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeService _homeService;

  HomeRepositoryImpl({required HomeService homeService}) : _homeService = homeService;

  @override
  Future<Either<Exception, HomeConfigModel>> getHomeConfig() async {
    try {
      final result = await _homeService.getHomeConfig();

      return result.fold((error) => Left(error), (config) {
        // Validate that config is not null
        if (config.order.isEmpty) {
          return Left(Exception('Invalid home config: empty order'));
        }
        return Right(config);
      });
    } catch (e) {
      return Left(Exception('Repository error: $e'));
    }
  }

  @override
  Future<Either<Exception, LocalityListResponse>> getLocalities(
    GetLocalitiesFilterModel filter,
  ) async {
    try {
      final result = await _homeService.getLocalities(filter);
      return result.fold((error) => Left(error), (response) => Right(response));
    } catch (e) {
      return Left(Exception('Repository error: $e'));
    }
  }

  @override
  Future<Either<Exception, UpdateLocalitySelectionResponseModel>> updateLocalitySelection(
    UpdateLocalitySelectionModel model,
  ) async {
    try {
      final result = await _homeService.updateLocalitySelection(model);
      return result.fold((error) => Left(error), (response) => Right(response));
    } catch (e) {
      return Left(Exception('Repository error: $e'));
    }
  }

  @override
  Future<Either<Exception, List<CompanyProfileModel>>> getCompanyProfiles({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final result = await _homeService.getCompanyProfiles(
        page: page,
        limit: limit,
      );
      return result.fold((error) => Left(error), (companies) => Right(companies));
    } catch (e) {
      return Left(Exception('Repository error: $e'));
    }
  }
}

final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  final homeService = ref.watch(homeServiceProvider);
  return HomeRepositoryImpl(homeService: homeService);
});
