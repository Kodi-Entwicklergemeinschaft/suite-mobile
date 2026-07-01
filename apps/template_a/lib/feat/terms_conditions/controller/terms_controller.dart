import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:preference_manager/shared_pref.dart';
import 'package:template_a/core/constant/storage_keys.dart';
import 'package:template_a/feat/auth/services/auth_service.dart';
import 'package:template_a/feat/terms_conditions/data/service/legal_service.dart';
import 'package:template_a/feat/user/profile/domain/usecases/save_notification_prefs_usecase.dart';

import 'terms_state.dart';

final termsControllerProvider =
    NotifierProvider<TermsController, TermsState>(() => TermsController());

class TermsController extends Notifier<TermsState> {
  @override
  TermsState build() => const TermsState();

  void toggleTerms() {
    state = state.copyWith(hasAcceptedConsent: !state.hasAcceptedConsent);
  }

  void toggleNotificationConsent() {
    state = state.copyWith(
      hasAcceptedPushNotification: !state.hasAcceptedPushNotification,
    );
  }

  void toggleNewsLetterConsent() {
    state = state.copyWith(hasAcceptedNewsLetter: true);
  }

  void resetTerms() {
    state = state.copyWith(
      hasAcceptedConsent: false,
      status: TermsStatusEnum.initial,
    );
  }

  void resetNotificationAndNewsLetter() {
    state = state.copyWith(
      hasAcceptedPushNotification: false,
      hasAcceptedNewsLetter: false,
    );
  }

  void goToNewsLetter() {
    state = state.copyWith(isNewsLetterScreen: true);
  }

  void goToTerms() {
    state = state.copyWith(isNewsLetterScreen: false);
  }

  Future<void> getLatestTerms() async {
    state = state.copyWith(status: TermsStatusEnum.loadingContent);
    try {
      final items = await ref.read(legalServiceProvider).getLegalConfig();
      String termsUrl = '';
      String privacyUrl = '';
      String imprintUrl = '';
      for (final item in items) {
        if (item.key == 'terms-of-use') termsUrl = item.url ?? '';
        if (item.key == 'privacy-policy') privacyUrl = item.url ?? '';
        if (item.key == 'imprint') imprintUrl = item.url ?? '';
      }
      state = state.copyWith(
        status: TermsStatusEnum.successContent,
        termsUrl: termsUrl,
        privacyUrl: privacyUrl,
        imprintUrl: imprintUrl,
      );
    } catch (_) {
      state = state.copyWith(status: TermsStatusEnum.successContent);
    }
  }

  // TODO: POST terms acceptance to backend.
  Future<void> saveTermsStatus() async {
    state = state.copyWith(status: TermsStatusEnum.loadingTermsAndCondition);
    final prefs = ref.read(preferenceManagerProvider);
    await prefs.saveBool(StorageKeys.isTermsAndConditionAccepted, state.hasAcceptedConsent);
    await Future.delayed(const Duration(milliseconds: 400));
    state = state.copyWith(status: TermsStatusEnum.successTermsAndCondition);
  }

  Future<void> saveNotificationStatus() async {
    state = state.copyWith(status: TermsStatusEnum.loadingNotificationPref);
    final prefs = ref.read(preferenceManagerProvider);

    await prefs.saveBool(StorageKeys.notificationsEnabled, state.hasAcceptedPushNotification);
    await prefs.saveBool(StorageKeys.newsletterEnabled, state.hasAcceptedNewsLetter);
    await prefs.saveBool(StorageKeys.isUserPreferencesSet, true);
    await prefs.saveBool(StorageKeys.isOnboarded, true);

    unawaited(
      ref.read(saveNotificationPrefsUseCaseProvider).call(
        SaveNotificationPrefsParams(
          notificationsEnabled: state.hasAcceptedPushNotification,
          newsletterSubscribed: state.hasAcceptedNewsLetter,
        ),
      ),
    );

    // Mark onboarded on the backend
    unawaited(ref.read(authServiceProvider).toggleOnboardedStatus(true));

    state = state.copyWith(status: TermsStatusEnum.successNotificationPref);
  }
}
