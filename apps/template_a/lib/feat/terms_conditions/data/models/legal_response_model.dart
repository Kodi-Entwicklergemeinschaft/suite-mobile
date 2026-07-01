import 'package:network/network.dart';

class LegalResponseModel extends BaseModel<LegalResponseModel> {
  bool success;
  List<LegalItemModel> data;

  LegalResponseModel({this.success = false, this.data = const []});

  @override
  LegalResponseModel fromJson(Map<String, dynamic> json) {
    return LegalResponseModel(
      success: json['success'] as bool? ?? false,
      data: (json['data'] as List<dynamic>? ?? [])
          .map((e) => LegalItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  Map<String, dynamic> toJson() => {'success': success};
}

class LegalItemModel {
  final String key;
  final String title;
  final String? url;

  const LegalItemModel({required this.key, required this.title, this.url});

  factory LegalItemModel.fromJson(Map<String, dynamic> json) {
    final url = (json['action']?['config']?['url'] as String?);
    return LegalItemModel(
      key: json['key'] as String? ?? '',
      title: json['title'] as String? ?? '',
      url: url,
    );
  }
}
