import 'package:template_c/core/constant/state_constant.dart';
import 'package:template_c/feat/interest/data/models/interest_config_response_model.dart';

class SearchFilterState {
  final StateConstant stateConstant;
  final List<InterestConfigCategories> groups;
  final List<InterestCategoriesChildern> selectedInterests;
  final String errorMessage;

  const SearchFilterState({
    this.stateConstant = StateConstant.loading,
    this.groups = const [],
    this.selectedInterests = const [],
    this.errorMessage = '',
  });

  SearchFilterState copyWith({
    StateConstant? stateConstant,
    List<InterestConfigCategories>? groups,
    List<InterestCategoriesChildern>? selectedInterests,
    String? errorMessage,
  }) {
    return SearchFilterState(
      stateConstant: stateConstant ?? this.stateConstant,
      groups: groups ?? this.groups,
      selectedInterests: selectedInterests ?? this.selectedInterests,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
