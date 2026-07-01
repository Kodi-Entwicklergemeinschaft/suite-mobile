import 'dart:convert';
import 'dart:developer' as dev;
import 'package:dartz/dartz.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:network/network.dart';
import '../data/models/home_config.dart';
import '../data/models/home_config_response_model.dart';
import '../data/models/get_localities_filter_model.dart';
import '../data/models/update_locality_selection_model.dart';
import '../data/models/update_locality_selection_response_model.dart';
import '../data/models/company_profile_model.dart';

class HomeService {
  final ApiHelper apiHelper;

  HomeService({required this.apiHelper});

  Future<Either<Exception, HomeConfigModel>> getHomeConfig() async {
    try {
      dev.log('[HomeService] Loading home config from local asset');
      final jsonStr = await rootBundle.loadString(
        'assets/config/homepage.json',
      );
      final data = json.decode(jsonStr) as Map<String, dynamic>;
      final response = HomeConfigResponseModel().fromJson(data);
      if (response.homeConfig != null) {
        dev.log('[HomeService] Loaded home config from asset');
        return Right(response.homeConfig!);
      }
      return Left(Exception('Invalid asset: home config is null'));
    } catch (e) {
      return Left(Exception('Failed to load home config: $e'));
    }
  }

  Future<Either<Exception, LocalityListResponse>> getLocalities(
    GetLocalitiesFilterModel filter,
  ) async {
    try {
      final result = await apiHelper.getRequest<LocalityListResponse>(
        path: '/api/localities',
        params: filter.toQueryParams(),
        create: () => LocalityListResponse(),
      );

      return result.fold(
        (error) {
          dev.log(
            '[HomeService] Failed to fetch localities: $error',
            error: error,
          );
          return Left(Exception('Failed to fetch localities: $error'));
        },
        (response) {
          dev.log(
            '[HomeService] Loaded ${response.items.length} localities (page ${response.meta.page}, hasNext: ${response.meta.hasNextPage})',
          );
          dev.log(
            '[HomeService] Selected locality IDs: ${response.userSelectedLocalityIds}',
          );

          // Mark items as selected based on userSelectedLocalityIds from API
          final itemsWithSelection = response.items.map((item) {
            return LocalityItem(
              id: item.id,
              code: item.code,
              name: item.name,
              description: item.description,
              centerLat: item.centerLat,
              centerLng: item.centerLng,
              sortOrder: item.sortOrder,
              isActive: item.isActive,
              createdAt: item.createdAt,
              updatedAt: item.updatedAt,
              isSelected: response.userSelectedLocalityIds.contains(item.id),
              image: item.image,
            );
          }).toList();

          return Right(
            LocalityListResponse(
              items: itemsWithSelection,
              userSelectedLocalityIds: response.userSelectedLocalityIds,
              meta: response.meta,
            ),
          );
        },
      );
    } catch (e, stackTrace) {
      dev.log(
        '[HomeService] Unexpected error fetching localities: $e',
        error: e,
        stackTrace: stackTrace,
      );
      return Left(Exception('Failed to fetch localities: $e'));
    }
  }

  /// Update user selected localities
  Future<Either<Exception, UpdateLocalitySelectionResponseModel>>
  updateLocalitySelection(UpdateLocalitySelectionModel model) async {
    try {
      dev.log(
        '[HomeService] Updating locality selection with ${model.localities.length} items',
      );

      final result = await apiHelper
          .postRequest<UpdateLocalitySelectionResponseModel>(
            path: '/api/localities/selection',
            body: model.toJson(),
            create: () => UpdateLocalitySelectionResponseModel(),
          );

      return result.fold(
        (error) {
          dev.log(
            '[HomeService] Failed to update locality selection: $error',
            error: error,
          );
          return Left(Exception('Failed to update selection: $error'));
        },
        (response) {
          // Validate response
          if (response.success ?? false) {
            dev.log('[HomeService] Successfully updated locality selection');
            return Right(response);
          } else {
            dev.log(
              '[HomeService] API returned success=false: ${response.message}',
            );
            return Left(
              Exception('API error: ${response.message ?? "Unknown error"}'),
            );
          }
        },
      );
    } catch (e, stackTrace) {
      dev.log(
        '[HomeService] Unexpected error updating selection: $e',
        error: e,
        stackTrace: stackTrace,
      );
      return Left(Exception('Failed to update selection: $e'));
    }
  }

  bool get _isLiveMode {
    final value = dotenv.maybeGet('BASE_URL') ?? '';
    return value.isNotEmpty && !value.startsWith('YOUR_');
  }

  /// Fetch company profiles — API when live, asset fallback otherwise
  Future<Either<Exception, List<CompanyProfileModel>>> getCompanyProfiles({
    int page = 1,
    int limit = 10,
    String? companySize,
    String? industry,
    String? location,
    String? sortBy,
    String? sortOrder,
  }) async {
    if (!_isLiveMode) {
      return _getCompanyProfilesFromAsset();
    }

    try {
      dev.log('[HomeService] Fetching random company profiles');

      final queryParams = <String, dynamic>{
        if (page > 1) 'page': page,
        if (limit != 10) 'limit': limit,
        if (companySize != null) 'companySize': companySize,
        if (industry != null) 'industry': industry,
        if (location != null) 'location': location,
        if (sortBy != null) 'sortBy': sortBy,
        if (sortOrder != null) 'sortOrder': sortOrder,
      };

      final result = await apiHelper.getRequest<CompanyProfileResponseModel>(
        path: '/api/business/job-matching/companies/random',
        params: queryParams.isNotEmpty ? queryParams : null,
        create: () => CompanyProfileResponseModel(),
      );

      return result.fold(
        (error) {
          dev.log(
            '[HomeService] Failed to fetch company profiles: $error',
            error: error,
          );
          return Left(Exception('Failed to fetch company profiles: $error'));
        },
        (response) {
          if (!response.success) {
            dev.log(
              '[HomeService] API returned success=false: ${response.message}',
            );
            return Left(
              Exception('API error: ${response.message ?? "Unknown error"}'),
            );
          }
          dev.log(
            '[HomeService] Loaded ${response.companies.length} random company profiles',
          );
          return Right(response.companies);
        },
      );
    } catch (e, stackTrace) {
      dev.log(
        '[HomeService] Unexpected error fetching companies: $e',
        error: e,
        stackTrace: stackTrace,
      );
      return Left(Exception('Failed to fetch company profiles: $e'));
    }
  }

  Future<Either<Exception, List<CompanyProfileModel>>>
  _getCompanyProfilesFromAsset() async {
    try {
      dev.log('[HomeService] Loading company profiles from local asset');
      final jsonStr = await rootBundle.loadString(
        'assets/config/companies.json',
      );
      final data = json.decode(jsonStr) as Map<String, dynamic>;
      final response = CompanyProfileResponseModel().fromJson(data);
      dev.log(
        '[HomeService] Loaded ${response.companies.length} companies from asset',
      );
      return Right(response.companies);
    } catch (e) {
      return Left(Exception('Failed to load companies from asset: $e'));
    }
  }
}

final homeServiceProvider = Provider<HomeService>((ref) {
  final apiHelper = ref.watch(apiHelperProvider);
  return HomeService(apiHelper: apiHelper);
});
