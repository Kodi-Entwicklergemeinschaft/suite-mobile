import 'dart:developer';
import 'dart:developer' as developer;

import 'package:common_components/common_components.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:network/network.dart';
import 'package:preference_manager/shared_pref.dart';
import 'package:template_c/core/constant/common_enums.dart';
import 'package:template_c/core/constant/state_constant.dart';
import 'package:template_c/core/constant/storage_keys.dart';
import 'package:template_c/feat/auth/data/models/request_model/guest_auth_request_model.dart';
import 'package:template_c/feat/auth/domain/usecases/guest_auth_usecase.dart';
import 'package:template_c/feat/onboarding/state/onboarding_state.dart';
import 'package:template_c/theme_config/domain/usecases/get_theme_config_usecase.dart';
import 'package:theme/theme.dart';

final onboardingControllerProvider =
    NotifierProvider.autoDispose<OnboardingController, OnboardingState>(() => OnboardingController());

class OnboardingController extends Notifier<OnboardingState> {

  GuestAuthUseCase get _guestAuthUseCase => ref.read(guestAuthUseCaseProvider);

  @override
  OnboardingState build() {
    return OnboardingState(StateConstant.loading);
  }

  Future<void> authenticateGuest() async {
    state = state.copyWith(stateConstant: StateConstant.loading);
    try {
      final prefs = ref.read(preferenceManagerProvider);
      final securePrefs = ref.read(securePreferencesProvider);

      var deviceId = prefs.getStringOrNull(StorageKeys.deviceId);

      final accessToken = await securePrefs.getString(
        StorageKeys.authAccessToken,
      );

      final userRole = prefs.getStringOrEmpty(
        StorageKeys.authRole,
      );
      
      final hasAccessToken = accessToken != null && accessToken.isNotEmpty;
      final isGuestUser = userRole == UserRole.guest.value;

      if (hasAccessToken && isGuestUser) {
        developer.log(
          'Token already exists (guest or real), skipping guest auth',
          name: 'OnboardingController._checkAndAuthenticateGuest',
        );
        return;
      }

      if (deviceId == null || deviceId.isEmpty) {
        deviceId = await DeviceInfoController.getDeviceUUID();
        if (deviceId == null || deviceId.isEmpty) {
          developer.log(
            'No device ID found, skipping guest auth',
            name: 'OnboardingController._checkAndAuthenticateGuest',
          );
          return;
        }
        await prefs.saveString(StorageKeys.deviceId, deviceId);
      }
      final guestAuthRequest = GuestAuthRequestModel(deviceId: deviceId);
      final result = await _guestAuthUseCase.call(guestAuthRequest);
      result.fold(
        (error) {
          developer.log(
            'Guest auth error: $error',
            name: 'OnboardingController._checkAndAuthenticateGuest',
            error: error,
          );
          state = state.copyWith(
            stateConstant: StateConstant.error,
            // message: error.toString(),
          );
          // Continue app without guest login
        },
        (guestResponse) {
          developer.log(
            'Guest authenticated: guestUserId=${guestResponse.id}, role=${guestResponse.role}',
            name: 'OnboardingController._checkAndAuthenticateGuest',
          );
          state = state.copyWith(
            stateConstant: StateConstant.success,
          );
        },
      );
    } catch (e, stackTrace) {
      developer.log(
        'Error during guest authentication: $e',
        name: 'OnboardingController._checkAndAuthenticateGuest',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

}
