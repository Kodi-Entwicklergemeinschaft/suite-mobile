import 'package:template_b/feat/home/data/models/home_config.dart';
import 'package:template_b/feat/home/data/models/company_profile_model.dart';
import 'package:template_b/feat/profile/data/models/faq_model.dart';

class HomeState {
  final HomeConfigModel? config;
  final bool isLoading;  // Only for pull-to-refresh
  final String? error;
  final bool isSuccess;

  /// Locality items fetched from /api/localities (separate from config)
  final List<LocalityItem> localityItems;

  /// Set of selected locality IDs (from API userSelectedLocalityIds)
  final Set<String> selectedLocalityIds;

  final int localityPage;
  final bool localityHasNextPage;
  final bool isLoadingMoreLocalities;

  /// Company profiles fetched from /api/business/job-matching/browse/companies
  final List<CompanyProfileModel> companyProfiles;

  /// Loading state for company profiles
  final bool isLoadingCompanyProfiles;

  /// Error state for company profiles
  final String? companyProfilesError;

  /// FAQ data
  final FAQModel? faqData;

  /// Incremented each time a locality toggle API call succeeds.
  /// Listeners watching this will only react to user-driven locality changes,
  /// not the initial load that sets selectedLocalityIds from the API response.
  final int localityToggleVersion;

  HomeState({
    this.isLoading = false,
    this.error,
    this.isSuccess = false,
    this.localityItems = const [],
    this.selectedLocalityIds = const {},
    this.localityPage = 1,
    this.localityHasNextPage = false,
    this.isLoadingMoreLocalities = false,
    this.config,
    this.companyProfiles = const [],
    this.isLoadingCompanyProfiles = false,
    this.companyProfilesError,
    this.faqData,
    this.localityToggleVersion = 0,
  });

  HomeState copyWith({
    bool? isLoading,
    String? error,
    bool? isSuccess,
    List<LocalityItem>? localityItems,
    Set<String>? selectedLocalityIds,
    int? localityPage,
    bool? localityHasNextPage,
    bool? isLoadingMoreLocalities,
    HomeConfigModel? config,
    List<CompanyProfileModel>? companyProfiles,
    bool? isLoadingCompanyProfiles,
    String? companyProfilesError,
    FAQModel? faqData,
    int? localityToggleVersion,
  }) {
    return HomeState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      isSuccess: isSuccess ?? this.isSuccess,
      localityItems: localityItems ?? this.localityItems,
      selectedLocalityIds: selectedLocalityIds ?? this.selectedLocalityIds,
      localityPage: localityPage ?? this.localityPage,
      localityHasNextPage: localityHasNextPage ?? this.localityHasNextPage,
      isLoadingMoreLocalities: isLoadingMoreLocalities ?? this.isLoadingMoreLocalities,
      config: config ?? this.config,
      companyProfiles: companyProfiles ?? this.companyProfiles,
      isLoadingCompanyProfiles: isLoadingCompanyProfiles ?? this.isLoadingCompanyProfiles,
      companyProfilesError: companyProfilesError ?? this.companyProfilesError,
      faqData: faqData ?? this.faqData,
      localityToggleVersion: localityToggleVersion ?? this.localityToggleVersion,
    );
  }

  /// Check if a locality is selected by its ID
  bool isLocalitySelected(String id) => selectedLocalityIds.contains(id);

  /// Get list of selected locality items from fetched locality data
  List<LocalityItem> get selectedLocalities {
    return localityItems
        .where((item) => selectedLocalityIds.contains(item.id))
        .toList();
  }
}
