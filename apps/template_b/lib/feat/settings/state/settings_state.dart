class SettingsState {
  final bool isDarkMode;
  final bool isNotificationEnabled;
  final String? notificationPreference;
  final bool isLoading;

  SettingsState({
    this.isDarkMode = true,
    this.isNotificationEnabled = false,
    this.notificationPreference,
    this.isLoading = false,
  });

  SettingsState copyWith({
    bool? isDarkMode,
    bool? isNotificationEnabled,
    String? notificationPreference,
    bool? isLoading,
  }) => SettingsState(
    isDarkMode: isDarkMode ?? this.isDarkMode,
    isNotificationEnabled: isNotificationEnabled ?? this.isNotificationEnabled,
    notificationPreference:
        notificationPreference ?? this.notificationPreference,
    isLoading: isLoading ?? this.isLoading,
  );
}
