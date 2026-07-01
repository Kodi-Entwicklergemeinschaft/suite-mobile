import 'package:flutter/material.dart';

/// UI-specific colors for homescreen sections, overlays, and component styling
class AppUIColors extends ThemeExtension<AppUIColors> {
  final Color overlayDark;
  final Color searchBarBackground;
  final Color searchBarBorder;
  final Color iconContainerBackground;
  final Color categoryText;
  final Color carouselLabel;
  final Color newsItemBackground;
  final Color dividerColor;

  const AppUIColors({
    required this.overlayDark,
    required this.searchBarBackground,
    required this.searchBarBorder,
    required this.iconContainerBackground,
    required this.categoryText,
    required this.carouselLabel,
    required this.newsItemBackground,
    required this.dividerColor,
  });

  @override
  AppUIColors copyWith({
    Color? overlayDark,
    Color? searchBarBackground,
    Color? searchBarBorder,
    Color? iconContainerBackground,
    Color? categoryText,
    Color? carouselLabel,
    Color? newsItemBackground,
    Color? dividerColor,
  }) {
    return AppUIColors(
      overlayDark: overlayDark ?? this.overlayDark,
      searchBarBackground: searchBarBackground ?? this.searchBarBackground,
      searchBarBorder: searchBarBorder ?? this.searchBarBorder,
      iconContainerBackground:
          iconContainerBackground ?? this.iconContainerBackground,
      categoryText: categoryText ?? this.categoryText,
      carouselLabel: carouselLabel ?? this.carouselLabel,
      newsItemBackground: newsItemBackground ?? this.newsItemBackground,
      dividerColor: dividerColor ?? this.dividerColor,
    );
  }

  @override
  AppUIColors lerp(AppUIColors? other, double t) {
    if (other is! AppUIColors) {
      return this;
    }
    return AppUIColors(
      overlayDark: Color.lerp(overlayDark, other.overlayDark, t) ?? overlayDark,
      searchBarBackground: Color.lerp(
              searchBarBackground, other.searchBarBackground, t) ??
          searchBarBackground,
      searchBarBorder:
          Color.lerp(searchBarBorder, other.searchBarBorder, t) ??
              searchBarBorder,
      iconContainerBackground: Color.lerp(
              iconContainerBackground, other.iconContainerBackground, t) ??
          iconContainerBackground,
      categoryText:
          Color.lerp(categoryText, other.categoryText, t) ?? categoryText,
      carouselLabel:
          Color.lerp(carouselLabel, other.carouselLabel, t) ?? carouselLabel,
      newsItemBackground: Color.lerp(
              newsItemBackground, other.newsItemBackground, t) ??
          newsItemBackground,
      dividerColor:
          Color.lerp(dividerColor, other.dividerColor, t) ?? dividerColor,
    );
  }

  static AppUIColors of(BuildContext context) {
    return Theme.of(context).extension<AppUIColors>()!;
  }
}
