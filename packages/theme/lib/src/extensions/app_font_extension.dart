import 'package:flutter/material.dart';

/// ThemeExtension that stores the active font family name from the API.
/// Font weight resolution is handled by FontResolver.
@immutable
class AppFontExtension extends ThemeExtension<AppFontExtension> {
  const AppFontExtension({required this.fontFamily});

  final String fontFamily;

  static AppFontExtension? of(BuildContext context) =>
      Theme.of(context).extension<AppFontExtension>();

  @override
  AppFontExtension copyWith({String? fontFamily}) =>
      AppFontExtension(fontFamily: fontFamily ?? this.fontFamily);

  @override
  AppFontExtension lerp(ThemeExtension<AppFontExtension>? other, double t) {
    if (other is! AppFontExtension) return this;
    return t < 0.5 ? this : other;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppFontExtension && other.fontFamily == fontFamily;

  @override
  int get hashCode => fontFamily.hashCode;
}
