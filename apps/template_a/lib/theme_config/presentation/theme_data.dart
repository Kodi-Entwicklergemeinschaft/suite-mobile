import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:template_a/core/utils/template_a_colors.dart';
import 'package:theme/theme.dart';

ThemeData buildThemeData(
  AppColors colors,
  Brightness brightness,
  AppFont font,
) {
  final isDark = brightness == Brightness.dark;

  // same as Kiel: dark = #00223F, light = #E7F1F6 (hardcoded, not from API)
  final bgColor = isDark
      ? TemplateAColors.darkModeBackground
      : TemplateAColors.lightModeBackground;

  // Kiel jaisa: surface = opposite of bg (light mode mein dark, dark mode mein light)
  final surfaceColor = isDark
      ? TemplateAColors.lightModeBackground
      : TemplateAColors.darkModeBackground;

  return ThemeData(
    brightness: brightness,
    primaryColor: colors.primary,
    scaffoldBackgroundColor: bgColor,
    colorScheme: isDark
        ? ColorScheme.dark(
            primary: colors.primary,
            onPrimary: Colors.white,
            secondary: colors.secondary,
            onSecondary: Colors.white,
            surface: surfaceColor,
            error: colors.error,
          )
        : ColorScheme.light(
            primary: colors.primary,
            onPrimary: Colors.white,
            secondary: colors.secondary,
            onSecondary: Colors.white,
            surface: surfaceColor,
            error: colors.error,
          ),
    useMaterial3: true,
    extensions: [
      AppTextColors(
        normal: isDark ? colors.fontLight : colors.fontDark,
        inverse: isDark ? colors.fontDark : colors.fontLight,
      ),
      AppContainerColors(
        normal: isDark
            ? TemplateAColors.lightModeBackground
            : TemplateAColors.darkModeBackground,
        inverse: isDark
            ? TemplateAColors.darkModeBackground
            : TemplateAColors.lightModeBackground,
      ),
      AppErrorColors(
        success: colors.success,
        warning: colors.warning,
        error: colors.error,
      ),
      isDark ? TemplateAThemeColors.dark : TemplateAThemeColors.light,
    ],

    appBarTheme: AppBarTheme(
      backgroundColor: bgColor,
      elevation: 0,
      surfaceTintColor: colors.primary.withValues(alpha: 0),
    ),

    iconButtonTheme: IconButtonThemeData(
      style: ButtonStyle(
        foregroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return colors.primary.withValues(alpha: 0.5);
          }
          return colors.primary;
        }),
        overlayColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.pressed)) {
            return colors.primary.withValues(alpha: 0.1);
          }
          return null;
        }),
      ),
    ),

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
            return colors.primary.withValues(alpha: 0.5);
          }
          return isDark ? colors.fontLight : colors.fontDark;
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

    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return colors.primary;
        }
        return null;
      }),
    ),

    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return isDark ? colors.fontDark : colors.fontLight;
        }
        return Colors.grey;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return colors.secondary;
        }
        return Colors.grey.shade600;
      }),
    ),

    datePickerTheme: DatePickerThemeData(
      backgroundColor: bgColor,
      surfaceTintColor: Colors.transparent,
      dividerColor: isDark ? Colors.white24 : Colors.black26,
      cancelButtonStyle: TextButton.styleFrom(
        foregroundColor: colors.secondary,
      ),
      confirmButtonStyle: TextButton.styleFrom(
        foregroundColor: colors.secondary,
      ),
      todayBorder: BorderSide(color: colors.secondary),
      todayForegroundColor: WidgetStateProperty.all(colors.secondary),
      dayForegroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return Colors.white;
        if (states.contains(WidgetState.disabled)) return isDark ? Colors.white38 : Colors.black26;
        return isDark ? colors.fontLight : colors.fontDark;
      }),
      headerForegroundColor: isDark ? colors.fontLight : colors.fontDark,
      yearForegroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return Colors.white;
        if (states.contains(WidgetState.disabled)) return isDark ? Colors.white38 : Colors.black26;
        return isDark ? colors.fontLight : colors.fontDark;
      }),
      dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return colors.secondary;
        return null;
      }),
    ),

    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: bgColor,
      surfaceTintColor: colors.primary.withValues(alpha: 0),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
    ),

    chipTheme: ChipThemeData(
      backgroundColor: isDark
          ? TemplateAColors.darkModeBackground
          : TemplateAColors.lightModeBackground,
      selectedColor: colors.secondary,
      labelStyle: const TextStyle(),
      side: const BorderSide(color: Colors.grey),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),

    dividerTheme: DividerThemeData(
      color: isDark ? const Color(0xff232C39) : const Color(0xffEBEBEB),
      thickness: 1,
      space: 1,
    ),

    dividerColor: isDark ? const Color(0xff232C39) : const Color(0xffEBEBEB),

    textTheme: _getTextTheme(
      font.fontFamily,
      isDark ? ThemeData.dark().textTheme : ThemeData.light().textTheme,
    ).apply(
      bodyColor: isDark ? colors.fontLight : colors.fontDark,
      displayColor: isDark ? colors.fontLight : colors.fontDark,
    ),
  );
}

TextTheme _getTextTheme(String fontFamily, TextTheme baseTheme) {
  try {
    return GoogleFonts.getTextTheme(fontFamily, baseTheme);
  } catch (e) {
    return GoogleFonts.robotoTextTheme(baseTheme);
  }
}
