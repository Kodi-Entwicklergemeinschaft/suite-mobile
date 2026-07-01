enum TermsStatusEnum {
  initial,
  loadingContent,
  successContent,
  errorContent,
  loadingTermsAndCondition,
  successTermsAndCondition,
  errorTermAndCondition,
  loadingNotificationPref,
  successNotificationPref,
  errorNotificationPref,
}

class TermsState {
  final TermsStatusEnum status;
  final bool hasAcceptedConsent;
  final bool hasAcceptedPushNotification;
  final bool hasAcceptedNewsLetter;
  final bool isNewsLetterScreen;
  final String termsContent;
  final String termsId;
  final String termsUrl;
  final String privacyUrl;
  final String imprintUrl;
  final String errorMessage;

  const TermsState({
    this.status = TermsStatusEnum.initial,
    this.hasAcceptedConsent = false,
    this.hasAcceptedPushNotification = false,
    this.hasAcceptedNewsLetter = false,
    this.isNewsLetterScreen = false,
    this.termsContent = '',
    this.termsId = '',
    this.termsUrl = '',
    this.privacyUrl = '',
    this.imprintUrl = '',
    this.errorMessage = '',
  });

  TermsState copyWith({
    TermsStatusEnum? status,
    bool? hasAcceptedConsent,
    bool? hasAcceptedPushNotification,
    bool? hasAcceptedNewsLetter,
    bool? isNewsLetterScreen,
    String? termsContent,
    String? termsId,
    String? termsUrl,
    String? privacyUrl,
    String? imprintUrl,
    String? errorMessage,
  }) {
    return TermsState(
      status: status ?? this.status,
      hasAcceptedConsent: hasAcceptedConsent ?? this.hasAcceptedConsent,
      hasAcceptedPushNotification:
          hasAcceptedPushNotification ?? this.hasAcceptedPushNotification,
      hasAcceptedNewsLetter:
          hasAcceptedNewsLetter ?? this.hasAcceptedNewsLetter,
      isNewsLetterScreen: isNewsLetterScreen ?? this.isNewsLetterScreen,
      termsContent: termsContent ?? this.termsContent,
      termsId: termsId ?? this.termsId,
      termsUrl: termsUrl ?? this.termsUrl,
      privacyUrl: privacyUrl ?? this.privacyUrl,
      imprintUrl: imprintUrl ?? this.imprintUrl,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
