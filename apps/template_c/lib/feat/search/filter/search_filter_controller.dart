import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:network/network.dart';
import 'package:template_c/core/constant/state_constant.dart';
import 'package:template_c/feat/interest/data/models/interest_config_response_model.dart';
import 'package:template_c/feat/interest/domain/usecases/get_interest_config_usecase.dart';
import 'package:template_c/feat/search/filter/search_filter_state.dart';

final searchFilterControllerProvider =
    NotifierProvider<SearchFilterController, SearchFilterState>(
  () => SearchFilterController(),
);

class SearchFilterController extends Notifier<SearchFilterState> {
  GetInterestConfigUsecase get _useCase =>
      ref.read(getInterestConfigUsecaseProvider);

  @override
  SearchFilterState build() => const SearchFilterState();

  Future<void> loadInterests() async {
    if (state.stateConstant == StateConstant.success ||
        state.stateConstant == StateConstant.loading && state.groups.isNotEmpty) {
      return;
    }
    state = state.copyWith(stateConstant: StateConstant.loading);
    final result = await _useCase.call(NoParams());
    result.fold(
      (error) => state = state.copyWith(
        stateConstant: StateConstant.error,
        errorMessage: error.toString(),
      ),
      (response) => state = state.copyWith(
        stateConstant: StateConstant.success,
        groups: response.data ?? [],
      ),
    );
  }

  void toggleInterest(InterestCategoriesChildern interest) {
    final current = List<InterestCategoriesChildern>.from(state.selectedInterests);
    if (current.contains(interest)) {
      current.remove(interest);
    } else {
      current.add(interest);
    }
    state = state.copyWith(selectedInterests: current);
  }

  void removeInterest(InterestCategoriesChildern interest) {
    final current = List<InterestCategoriesChildern>.from(state.selectedInterests)
      ..remove(interest);
    state = state.copyWith(selectedInterests: current);
  }

  void clearAll() {
    state = state.copyWith(selectedInterests: []);
  }

  bool isSelected(InterestCategoriesChildern interest) =>
      state.selectedInterests.contains(interest);
}
