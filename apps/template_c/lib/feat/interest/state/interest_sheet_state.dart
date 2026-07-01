import 'package:template_c/core/constant/common_enums.dart';
import 'package:template_c/feat/interest/data/models/interest_config_response_model.dart';
import 'package:template_c/feat/interest/data/models/selected_response_model.dart';

class InterestSheetState {


  final StateEnum state;
  final String? message;

  //initial load config state
  final bool loadingConfig;
  final bool isConfigLoaded;
  final bool isLoadingConfigError;
  final String? loadingConfigMessage;

  final InterestConfigResponseModel? data;
  final Map<String, String> idToTitle;

  //load selected interest state
  final bool loadingSelectedInterests;
  final bool isSelectedInterestsLoaded;
  final bool isLoadingSelectedInterestsError;
  final String? loadingSelectedInterestsMessage;

  final SelectedResponseModel? selectedIds;


  const InterestSheetState({
    this.state = StateEnum.initial,
    this.message,

    this.loadingConfig = false,
    this.isConfigLoaded = false,
    this.isLoadingConfigError = false,
    this.loadingConfigMessage,

    this.data,
    this.idToTitle = const {},

    this.loadingSelectedInterests = false,
    this.isSelectedInterestsLoaded = false,
    this.isLoadingSelectedInterestsError = false,
    this.loadingSelectedInterestsMessage,

    this.selectedIds,
  });

  InterestSheetState copyWith({
    StateEnum? state,
    String? message,

    bool? loadingConfig,
    bool? isConfigLoaded,
    bool? isLoadingConfigError,
    String? loadingConfigMessage,

    InterestConfigResponseModel? data,
    Map<String, String>? idToTitle,

    bool? loadingSelectedInterests,
    bool? isSelectedInterestsLoaded,
    bool? isLoadingSelectedInterestsError,
    String? loadingSelectedInterestsMessage,

    SelectedResponseModel? selectedIds,
  }) {
    return InterestSheetState(
      state: state ?? this.state,
      message: message ?? this.message,

      loadingConfig: loadingConfig ?? this.loadingConfig,
      isConfigLoaded: isConfigLoaded ?? this.isConfigLoaded,
      isLoadingConfigError: isLoadingConfigError ?? this.isLoadingConfigError,
      loadingConfigMessage: loadingConfigMessage ?? this.loadingConfigMessage,

      data: data ?? this.data,
      idToTitle: idToTitle ?? this.idToTitle,

      loadingSelectedInterests: loadingSelectedInterests ?? this.loadingSelectedInterests,
      isSelectedInterestsLoaded: isSelectedInterestsLoaded ?? this.isSelectedInterestsLoaded,
      isLoadingSelectedInterestsError: isLoadingSelectedInterestsError ?? this.isLoadingSelectedInterestsError,
      loadingSelectedInterestsMessage: loadingSelectedInterestsMessage ?? this.loadingSelectedInterestsMessage,

      selectedIds: selectedIds ?? this.selectedIds,
    );
  }

  /// ✅ Derived data (UI friendly)
  List<String> get selectedIdList =>
      selectedIds?.data?.subcategoryIds ?? const [];

  List<String> get selectedTitles => selectedIdList
      .map((id) => idToTitle[id])
      .whereType<String>()
      .where((title) => title.isNotEmpty)
      .toList();
}
