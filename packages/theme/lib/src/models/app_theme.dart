import 'app_colors.dart';
import 'app_assets.dart';
import 'app_font.dart';

class AppTheme {
  final AppColors colors;
  final AppAssets? assets;
  final AppFont font;
  final String? title;
  final String? description;

  const AppTheme({
    required this.colors,
    this.assets,
    required this.font,
    this.title,
    this.description,
  });

  factory AppTheme.fromJson(Map<String, dynamic> json) {
    return AppTheme(
      colors: AppColors.fromJson(json['colors'] as Map<String, dynamic>? ?? {}),
      assets: AppAssets.fromJson(json['assets'] as Map<String, dynamic>? ?? {}),
      font: AppFont.fromJson(json['font'] as Map<String, dynamic>? ?? {}),
      title: json['title'] as String?,
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'colors': colors.toJson(),
      'assets': assets?.toJson(),
      'font': font.toJson(),
      'title': title,
      'description': description,
    };
  }

  static const defaultTheme = AppTheme(
    colors: AppColors.defaultColors,
    font: AppFont.defaultFont,
  );
}
