import 'package:network/network.dart';

class ListingMediaModel implements BaseModel {
  final String? id;
  final String? type;
  final String? url;
  final String? altText;
  final String? caption;
  final int? order;

  ListingMediaModel({
    this.id,
    this.type,
    this.url,
    this.altText,
    this.caption,
    this.order,
  });

  @override
  ListingMediaModel fromJson(Map<String, dynamic> json) {
    return ListingMediaModel(
      id: json['id'] as String?,
      type: json['type'] as String?,
      url: json['url'] as String?,
      altText: json['altText'] as String?,
      caption: json['caption'] as String?,
      order: json['order'] as int?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type,
    'url': url,
    'altText': altText,
    'caption': caption,
    'order': order,
  };
}
