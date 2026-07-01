class AppAssets {
  final String logoUrl;
  final String splashUrl;
  final String? contactUsUrl;

  const AppAssets({
    required this.logoUrl,
    required this.splashUrl,
    this.contactUsUrl,
  });

  factory AppAssets.fromJson(Map<String, dynamic> json) {
    return AppAssets(
      logoUrl: json['logoUrl'] as String? ?? '',
      splashUrl: json['splashUrl'] as String? ?? '',
      contactUsUrl: json['contactUsUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'logoUrl': logoUrl,
      'splashUrl': splashUrl,
      if (contactUsUrl != null) 'contactUsUrl': contactUsUrl,
    };
  }

}
