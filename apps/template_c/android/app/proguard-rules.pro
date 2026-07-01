# ── device_calendar ───────────────────────────────────────────────────────────
# The plugin uses reflection to access Android's CalendarContract content
# provider classes. R8/ProGuard will strip or rename them in release builds,
# causing retrieveCalendars() to return empty data even when permission is
# granted. Keep the entire plugin package to prevent this.
-keep class com.builttoroam.devicecalendar.** { *; }
-keepnames class com.builttoroam.devicecalendar.** { *; }

# Android CalendarContract projection fields accessed via reflection
-keepclassmembers class android.provider.CalendarContract$* {
    public static final java.lang.String *;
}
