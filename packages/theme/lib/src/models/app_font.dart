class AppFont {
  final String fontFamily;
  final String? secondaryFontFamily;

  const AppFont({
    required this.fontFamily,
    this.secondaryFontFamily,
  });

  factory AppFont.fromJson(Map<String, dynamic> json) {
    return AppFont(
      fontFamily: json['fontFamily'] ?? 'Roboto',
      secondaryFontFamily: json['secondaryFontFamily'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fontFamily': fontFamily,
      'secondaryFontFamily': secondaryFontFamily,
    };
  }

  // Default fallback - Roboto is always available in google_fonts
  static const defaultFont = AppFont(
    fontFamily: 'Roboto',
  );
}
