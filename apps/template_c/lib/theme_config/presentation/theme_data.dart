import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:template_c/core/utils/template_c_colors.dart';
import 'package:theme/theme.dart';

ThemeData buildThemeData(
  AppColors colors,
  Brightness brightness,
  AppFont font,
) {
  final isDark = brightness == Brightness.dark;
  final baseTheme = isDark
      ? ThemeData.dark().textTheme
      : ThemeData.light().textTheme;

  return ThemeData(
    brightness: brightness,
    primaryColor: colors.primary,
    scaffoldBackgroundColor: isDark
        ? TemplateCColors.darkModeBackground
        : TemplateCColors.lightModeBackground,
    colorScheme: isDark
        ? ColorScheme.dark(
            primary: colors.primary,
            secondary: colors.secondary,
            error: colors.error,
          )
        : ColorScheme.light(
            primary: colors.primary,
            secondary: colors.secondary,
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
            ? TemplateCColors.lightModeBackground
            : TemplateCColors.darkModeBackground,
        inverse: isDark ? colors.lightBackground : colors.darkBackground,
      ),
      AppErrorColors(
        success: colors.primary,
        warning: colors.warning,
        error: colors.error,
      ),
      (isDark ? AppFeatureColors.dark : AppFeatureColors.light).copyWith(
        activeChipBackground: colors.secondary,
        activeChipForeground: isDark ? colors.fontLight : colors.fontDark,
      ),
      (isDark ? TemplateCThemeColors.dark : TemplateCThemeColors.light)
          .copyWith(
            secondaryTextTheme: font.secondaryFontFamily != null
                ? _getTextTheme(font.secondaryFontFamily!, baseTheme).apply(
                    bodyColor: isDark ? colors.fontLight : colors.fontDark,
                    displayColor: isDark ? colors.fontLight : colors.fontDark,
                  )
                : null,
            splashGradient: LinearGradient(
              begin: Alignment(0.9, -1.0),
              end: Alignment(-0.9, 1.0),
              colors: [
                _generateGradientColor(colors.primary),
                colors.primary,
                colors.primary,
              ],
              stops: const [0.00, 0.5805, 1.0],
            ),
          ),
    ],

    // App Bar Theme
    appBarTheme: AppBarTheme(
      backgroundColor: isDark
          ? TemplateCColors.darkModeBackground
          : TemplateCColors.lightModeBackground,
      elevation: 0,
      surfaceTintColor: colors.primary.withValues(alpha: 0),
    ),

    // Icon Button Theme
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

    // Chip Theme
    // chipTheme: ChipThemeData(
    //   backgroundColor: backgroundColor.withValues(alpha: 0),
    //   disabledColor: colors.secondary.withValues(alpha: 0.3),
    //   selectedColor: colors.primary,
    //   secondarySelectedColor: colors.primary,
    //   padding: const EdgeInsets.symmetric(horizontal: 8),
    //   labelStyle: TextStyle(color: textColor),
    //   secondaryLabelStyle: TextStyle(color: backgroundColor),
    //   side: BorderSide(color: colors.secondary),
    //   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    // ),

    // Switch Theme
    // switchTheme: SwitchThemeData(
    //   thumbColor: WidgetStateProperty.resolveWith((states) {
    //     if (states.contains(WidgetState.selected)) {
    //       return colors.secondary.withValues(alpha: 0.6);
    //     }
    //     return colors.secondary.withValues(alpha: 0.6);
    //   }),
    //   trackColor: WidgetStateProperty.resolveWith((states) {
    //     if (states.contains(WidgetState.selected)) {
    //       return Color.fromRGBO(2, 128, 255, 1);
    //     }
    //     return isDark?Color.fromRGBO(48, 61, 80, 1):Color.fromRGBO(235, 235, 235, 1);
    //   }),
    // ),

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
    // dialogTheme: DialogThemeData(
    //   backgroundColor: surfaceColor,
    //   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    //   surfaceTintColor: colors.primary.withValues(alpha: 0),
    // ),

    // Bottom Sheet Theme
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: isDark
          ? TemplateCColors.darkModeBackground
          : TemplateCColors.lightModeBackground,
      surfaceTintColor: colors.primary.withValues(alpha: 0),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
    ),

    // Tab Bar Theme
    // tabBarTheme: TabBarThemeData(
    //   indicatorColor: colors.primary,
    //   labelColor: colors.primary,
    //   unselectedLabelColor: textSecondaryColor,
    //   labelStyle: const TextStyle(fontWeight: FontWeight.w600),
    // ),

    // Divider Theme
    dividerTheme: DividerThemeData(
      color: isDark ? Color(0xff232C39) : Color(0xffEBEBEB),
      thickness: 1,
      space: 1,
    ),

    dividerColor: isDark ? Color(0xff232C39) : Color(0xffEBEBEB),

    // Text Theme
    textTheme: _getTextTheme(font.fontFamily, baseTheme).apply(
      bodyColor: isDark ? colors.fontLight : colors.fontDark,
      displayColor: isDark ? colors.fontLight : colors.fontDark,
    ),
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

Color _generateGradientColor(Color baseColor) {
  final hsl = HSLColor.fromColor(baseColor);

  // 🎯 Tunable parameters (you can tweak later if needed)
  const double hueShift = -15; // slight shift toward vibrant tone
  const double lightnessBoost = 0.14; // make it brighter
  const double saturationBoost = 0.05; // enhance vibrancy

  final double newHue = (hsl.hue + hueShift) % 360;
  final double newLightness = (hsl.lightness + lightnessBoost).clamp(0.0, 1.0);
  final double newSaturation = (hsl.saturation + saturationBoost).clamp(
    0.0,
    1.0,
  );

  return hsl
      .withHue(newHue)
      .withLightness(newLightness)
      .withSaturation(newSaturation)
      .toColor();
}
