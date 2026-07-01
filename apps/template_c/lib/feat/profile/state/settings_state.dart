import 'package:template_c/core/constant/common_enums.dart';

class SettingsState {
  final bool darkModeEnabled;
  final StateEnum state;
  final String? errorMessage;

  const SettingsState({
    required this.darkModeEnabled,
    this.state = StateEnum.initial,
    this.errorMessage,
  });

  SettingsState copyWith({
    bool? darkModeEnabled,
    StateEnum? state,
    String? errorMessage,
  }) {
    return SettingsState(
      darkModeEnabled: darkModeEnabled ?? this.darkModeEnabled,
      state: state ?? this.state,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
