import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:theme/theme.dart';

ThemeData buildThemeData(
  AppColors colors,
  Brightness brightness,
  AppFont font,
) {
  final isDark = brightness == Brightness.dark;

  // Derive colors based on brightness
  final backgroundColor = colors.getBackground(isDark);
  final surfaceColor = colors.getSurface(isDark);
  final textColor = colors.getTextColor(isDark);
  final textSecondaryColor = colors.getTextSecondary(isDark);
  final dividerColor = colors.dividerColor;

  return ThemeData(
    brightness: brightness,
    primaryColor: colors.primary,
    scaffoldBackgroundColor: backgroundColor,
    colorScheme: isDark
        ? ColorScheme.dark(
            primary: colors.primary,
            secondary: colors.secondary,
            surface: surfaceColor,
            error: colors.error,
          )
        : ColorScheme.light(
            primary: colors.primary,
            secondary: colors.secondary,
            surface: surfaceColor,
            error: colors.error,
          ),
    useMaterial3: true,
    extensions: [
      AppTextColors(
        normal: textColor,
        inverse: isDark ? colors.fontDark : colors.fontLight,
      ),
      AppContainerColors(
        normal: backgroundColor,
        inverse: isDark ? colors.lightBackground : colors.darkBackground,
      ),
      AppErrorColors(
        success: colors.success,
        warning: colors.warning,
        error: colors.error,
      ),
    ],

    // App Bar Theme
    appBarTheme: AppBarTheme(
      backgroundColor: colors.primary,
      foregroundColor: backgroundColor,
      elevation: 0,
      surfaceTintColor: colors.primary.withValues(alpha: 0),
    ),

    // Icon Button Theme
    iconButtonTheme: IconButtonThemeData(
      style: ButtonStyle(
        foregroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return textSecondaryColor.withValues(alpha: 0.5);
          }
          return textColor;
        }),
        overlayColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.pressed)) {
            return colors.primary.withValues(alpha: 0.1);
          }
          return null;
        }),
      ),
    ),

    // Outlined Button Theme
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: ButtonStyle(
        minimumSize: WidgetStateProperty.all(const Size(0, 48)),
        padding: WidgetStateProperty.all(
          const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        ),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
        ),
        side: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return BorderSide(color: colors.secondary.withValues(alpha: 0.5));
          }
          return BorderSide(color: colors.primary);
        }),
        foregroundColor: WidgetStateProperty.all(colors.primary),
        overlayColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.pressed)) {
            return colors.primary.withValues(alpha: 0.1);
          }
          return null;
        }),
      ),
    ),

    // Elevated Button Theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        minimumSize: WidgetStateProperty.all(const Size(0, 48)),
        padding: WidgetStateProperty.all(
          const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        ),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
        ),
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return colors.secondary.withValues(alpha: 0.3);
          }
          if (states.contains(WidgetState.pressed)) {
            return colors.primary.withValues(alpha: 0.8);
          }
          return colors.primary;
        }),
        foregroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return textSecondaryColor.withValues(alpha: 0.5);
          }
          return backgroundColor;
        }),
        elevation: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) return 0.0;
          if (states.contains(WidgetState.pressed)) return 2.0;
          return 1.0;
        }),
        overlayColor: WidgetStateProperty.all(
          colors.primary.withValues(alpha: 0),
        ),
      ),
    ),

    // Chip Theme
    chipTheme: ChipThemeData(
      backgroundColor: backgroundColor.withValues(alpha: 0),
      disabledColor: colors.secondary.withValues(alpha: 0.3),
      selectedColor: colors.primary,
      secondarySelectedColor: colors.primary,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      labelStyle: TextStyle(color: textColor),
      secondaryLabelStyle: TextStyle(color: backgroundColor),
      side: BorderSide(color: colors.secondary),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),

    // Switch Theme
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return backgroundColor;
        }
        return colors.secondary.withValues(alpha: 0.6);
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return colors.primary;
        }
        return colors.secondary;
      }),
    ),

    // Radio Theme
    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return colors.primary;
        }
        return null;
      }),
    ),

    // Dialog Theme
    dialogTheme: DialogThemeData(
      backgroundColor: surfaceColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      surfaceTintColor: colors.primary.withValues(alpha: 0),
    ),

    // Bottom Sheet Theme
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: surfaceColor,
      surfaceTintColor: colors.primary.withValues(alpha: 0),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
    ),

    // Tab Bar Theme
    tabBarTheme: TabBarThemeData(
      indicatorColor: colors.primary,
      labelColor: colors.primary,
      unselectedLabelColor: textSecondaryColor,
      labelStyle: const TextStyle(fontWeight: FontWeight.w600),
    ),

    // Divider Theme
    dividerTheme: DividerThemeData(color: dividerColor, thickness: 1, space: 1),

    // Text Theme
    textTheme: _getTextTheme(
      font.fontFamily,
      isDark ? ThemeData.dark().textTheme : ThemeData.light().textTheme,
    ).apply(bodyColor: textColor, displayColor: textColor),
  );
}

/// Get text theme from Google Fonts with fallback to system fonts
TextTheme _getTextTheme(String fontFamily, TextTheme baseTheme) {
  try {
    // Try to get the font from Google Fonts
    return GoogleFonts.getTextTheme(fontFamily, baseTheme);
  } catch (e) {
    // Fallback to Roboto if font loading fails (offline, network issue, etc)
    return GoogleFonts.robotoTextTheme(baseTheme);
  }
}
