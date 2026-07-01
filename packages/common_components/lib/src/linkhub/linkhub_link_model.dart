class LinkhubLinkModel {
  final String title;
  final String url;
  final String action;
  final String? image;

  const LinkhubLinkModel({
    required this.title,
    required this.url,
    required this.action,
    this.image,
  });

  bool get isWebview => action == 'url_webview';
  bool get isBrowser => action == 'url_browser';

  factory LinkhubLinkModel.fromJson(Map<String, dynamic> json) {
    return LinkhubLinkModel(
      title: json['title']?.toString() ?? '',
      url: json['url']?.toString() ?? '',
      action: json['action']?.toString() ?? 'url_browser',
      image: json['image']?.toString(),
    );
  }
}
