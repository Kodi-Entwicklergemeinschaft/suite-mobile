import 'package:template_a/core/constant/common_enums.dart';
import 'package:template_a/feat/user/profile/model/response_model/get_salutation_response_model.dart';

class ProfileState {
  final StateEnum status;
  final String? message;
  final String firstName;
  final String lastName;
  final String? userId;
  final String? email;
  final String? profilePhotoUrl;
  final String? salutationCode;
  final List<SalutationItem> salutationsList;
  final List<String> salutationLabels;
  final List<String> enabledLanguages;
  final String? defaultLanguage;
  final bool isLoadingLanguages;
  final bool notificationsEnabled;
  final bool newsletterSubscribed;
  final bool isLoadingNotificationPrefs;
  final bool deviceNotificationGranted;
  final String? preferredLanguage;

  const ProfileState({
    this.status = StateEnum.initial,
    this.message,
    this.firstName = '',
    this.lastName = '',
    this.userId,
    this.email,
    this.profilePhotoUrl,
    this.salutationCode,
    this.salutationsList = const [],
    this.salutationLabels = const [],
    this.enabledLanguages = const [],
    this.defaultLanguage,
    this.isLoadingLanguages = false,
    this.notificationsEnabled = false,
    this.newsletterSubscribed = false,
    this.isLoadingNotificationPrefs = false,
    this.deviceNotificationGranted = false,
    this.preferredLanguage,
  });

  bool get isLoading => status == StateEnum.loading;
  bool get isSubmitting => status == StateEnum.loadingDialog;

  ProfileState copyWith({
    StateEnum? status,
    String? message,
    bool clearMessage = false,
    String? firstName,
    String? lastName,
    String? userId,
    String? email,
    String? profilePhotoUrl,
    String? salutationCode,
    List<SalutationItem>? salutationsList,
    List<String>? salutationLabels,
    List<String>? enabledLanguages,
    String? defaultLanguage,
    bool? isLoadingLanguages,
    bool? notificationsEnabled,
    bool? newsletterSubscribed,
    bool? isLoadingNotificationPrefs,
    bool? deviceNotificationGranted,
    String? preferredLanguage,
  }) {
    return ProfileState(
      status: status ?? this.status,
      message: clearMessage ? null : message ?? this.message,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      userId: userId ?? this.userId,
      email: email ?? this.email,
      profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
      salutationCode: salutationCode ?? this.salutationCode,
      salutationsList: salutationsList ?? this.salutationsList,
      salutationLabels: salutationLabels ?? this.salutationLabels,
      enabledLanguages: enabledLanguages ?? this.enabledLanguages,
      defaultLanguage: defaultLanguage ?? this.defaultLanguage,
      isLoadingLanguages: isLoadingLanguages ?? this.isLoadingLanguages,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      newsletterSubscribed: newsletterSubscribed ?? this.newsletterSubscribed,
      isLoadingNotificationPrefs: isLoadingNotificationPrefs ?? this.isLoadingNotificationPrefs,
      deviceNotificationGranted: deviceNotificationGranted ?? this.deviceNotificationGranted,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
    );
  }
}