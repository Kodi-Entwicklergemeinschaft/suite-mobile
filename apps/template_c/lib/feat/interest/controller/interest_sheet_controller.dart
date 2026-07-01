import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:network/network.dart';
import 'package:preference_manager/shared_pref.dart';
import 'package:template_c/core/constant/common_enums.dart';
import 'package:template_c/core/constant/storage_keys.dart';
import 'package:template_c/feat/interest/data/models/selected_response_model.dart';
import 'package:template_c/feat/interest/domain/usecases/get_interest_config_usecase.dart';
import 'package:template_c/feat/interest/domain/usecases/get_selected_intereset_usecase.dart';
import 'package:template_c/feat/interest/domain/usecases/toggle_onboarded_status_usecase.dart';
import 'package:template_c/feat/interest/domain/usecases/update_selected_interest_usecase.dart';
import 'package:template_c/feat/interest/state/interest_sheet_state.dart';

class InterestSheetController extends Notifier<InterestSheetState>{

  late GetInterestConfigUsecase _getInterestConfigUsecase;
  late GetSelectedInterestUsecase _getSelectedInterestUsecase;
  late UpdateSelectedInterestUsecase _updateSelectedInterestUsecase;
  late  ToggleOnboardedStatusUsecase _toggleOnboardedStatusUsecase;
  late AppPreferenceManager _appPreferenceManager;

  @override
  InterestSheetState build() {
    _getInterestConfigUsecase = ref.read(getInterestConfigUsecaseProvider);
    _getSelectedInterestUsecase = ref.read(getSelectedInterestUsecaseProvider);
    _updateSelectedInterestUsecase = ref.read(updateSelectedInterestUsecaseProvider);
    _toggleOnboardedStatusUsecase = ref.read(toggleOnboardedStatusUsecaseProvider);
    _appPreferenceManager=ref.read(preferenceManagerProvider);

    final link = ref.keepAlive();
    Timer? cancelTimer;
    ref.onCancel(() {
      cancelTimer = Timer(const Duration(milliseconds: 500), link.close);
    });
    ref.onResume(() {
      cancelTimer?.cancel();
      cancelTimer = null;
    });

    Future.microtask(() {
      getInterestConfig();
    });

    return InterestSheetState(state: StateEnum.initial);
  }

  Future<void> getInterestConfig() async {
    state = state.copyWith(
      loadingConfig: true,
      isLoadingConfigError: false,
      isLoadingSelectedInterestsError: false,
    );

    final response = await _getInterestConfigUsecase.call(NoParams());

    response.fold(
      (error) {
        state = state.copyWith(
          isLoadingConfigError: true,
          loadingConfig: false,
          loadingConfigMessage: error.toString(),
        );
      },
      (data) {
        final idToTitle = <String, String>{};

        for (final category in data.data ?? []) {
          for (final child in category.children ?? []) {
            final id = child.id;
            final title = child.title;

            if (id != null && title != null) {
              idToTitle[id] = title;
            }
          }
        }

        state = state.copyWith(
          isLoadingConfigError: false,
          loadingConfig: false,
          isConfigLoaded: true,
          data: data,
          idToTitle: idToTitle,
          loadingConfigMessage: data.message,
        );
      },
    );
    if(state.isConfigLoaded){
      getSelectedInterest();
    }
  }

  void getSelectedInterest() async {
    state = state.copyWith(loadingSelectedInterests: true, isLoadingSelectedInterestsError: false);

    final result = await _getSelectedInterestUsecase.call(NoParams());
    result.fold(
      (error) {
        state = state.copyWith(
          isLoadingSelectedInterestsError: true,
          loadingSelectedInterests: false,
          loadingSelectedInterestsMessage: error.toString(),
        );
      },
      (selectedInterest) {
        state = state.copyWith(
          isLoadingSelectedInterestsError: false,
          loadingSelectedInterests: false,
          isSelectedInterestsLoaded: true,
          selectedIds: selectedInterest,
          loadingSelectedInterestsMessage: selectedInterest.message,
        );
      },
    );
  }

  void updateSelected(List<String> subcategoryIds) {
    final current = state.selectedIds;
    state = state.copyWith(
      selectedIds: SelectedResponseModel(
        success: current?.success,
        message: current?.message,
        data: SelectedData(subcategoryIds: subcategoryIds),
      ),
    );
  }

  void applySelectedInterest(bool isSheet) async {
    if (state.state == StateEnum.loading) return;

    final keepAlive = ref.keepAlive();
    state = state.copyWith(state: StateEnum.loading);

    final result =
        await _updateSelectedInterestUsecase.call(state.selectedIdList);

    result.fold(
      (error) {
        developer.log(
          'Update Interest Error: $error',
          name: 'InterestSheetController.applySelectedInterest',
          error: error,
        );
        state = state.copyWith(
          message: error.toString(),
          state: StateEnum.error,
        );
      },
      (selectedInterest) {
        state = state.copyWith(
          selectedIds: selectedInterest,
          state: StateEnum.success,
        );
      },
    );

    if (state.state == StateEnum.success) {
      final isGuestUser = _appPreferenceManager.getStringOrNull(StorageKeys.authRole) == UserRole.guest.toString();
      if (!isSheet && !isGuestUser) {
        updateOnboarded();
      }
    }

    keepAlive.close();
  }

  void updateOnboarded() async {
    final result = await _toggleOnboardedStatusUsecase.call(true);

    result.fold(
      (error){
        developer.log(
          'Toggle onboarding error: $error',
          name: 'InterestSheetController.updateInterest',
          error: error,
        );
      },
      (data){
        _appPreferenceManager.saveBool(StorageKeys.isOnboarded, true);
      }
    );
  }
}

final interestSheetControllerProvider =
    NotifierProvider.autoDispose<InterestSheetController, InterestSheetState>(
      () => InterestSheetController(),
    );
