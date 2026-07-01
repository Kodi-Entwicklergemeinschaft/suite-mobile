import 'package:template_c/core/constant/common_enums.dart';
import 'package:template_c/feat/profile/data/models/profile_model.dart';

class ProfileState {
  final StateEnum state;
  final String? message;
  final ProfileModel? data;
  final bool isGuestUser;
  final bool notificationsEnabled;
  final String version;

  const ProfileState({
    this.state = StateEnum.initial,
    this.message,
    this.data,
    this.isGuestUser = false,
    this.notificationsEnabled = false,
    this.version = '',
  });

  ProfileState copyWith({
    StateEnum? state,
    String? message,
    ProfileModel? data,
    bool? isGuestUser,
    bool? notificationsEnabled,
    String? version,
  }) {
    return ProfileState(
      state: state ?? this.state,
      message: message ?? this.message,
      data: data ?? this.data,
      isGuestUser: isGuestUser ?? this.isGuestUser,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      version: version ?? this.version,
    );
  }
}
