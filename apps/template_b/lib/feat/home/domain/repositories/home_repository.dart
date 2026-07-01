import 'package:dartz/dartz.dart';
import 'package:template_b/feat/home/data/models/home_config.dart';
import 'package:template_b/feat/home/data/models/get_localities_filter_model.dart';
import 'package:template_b/feat/home/data/models/update_locality_selection_model.dart';
import 'package:template_b/feat/home/data/models/update_locality_selection_response_model.dart';
import 'package:template_b/feat/home/data/models/company_profile_model.dart';

abstract class HomeRepository {
  /// Fetch home configuration from API endpoint
  Future<Either<Exception, HomeConfigModel>> getHomeConfig();

  Future<Either<Exception, LocalityListResponse>> getLocalities(GetLocalitiesFilterModel filter);

  /// Update user selected localities
  Future<Either<Exception, UpdateLocalitySelectionResponseModel>> updateLocalitySelection(
    UpdateLocalitySelectionModel model,
  );

  /// Fetch company profiles from job matching
  Future<Either<Exception, List<CompanyProfileModel>>> getCompanyProfiles({
    int page = 1,
    int limit = 10,
  });
}
