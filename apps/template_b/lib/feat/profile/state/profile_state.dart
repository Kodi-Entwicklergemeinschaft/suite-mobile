import 'package:template_b/core/constants/common_enums.dart';
import 'package:template_b/feat/profile/data/models/profile_model.dart';

class ProfileState {
  final StateEnum state;
  final String? message;
  final ProfileModel? data;

  ProfileState({
    this.state = StateEnum.initial,
    this.message,
    this.data,
  });

  ProfileState copyWith({
    StateEnum? state,
    String? message,
    ProfileModel? data,
  }) => ProfileState(
    state: state ?? this.state,
    message: message,
    data: data ?? this.data,
  );
}
