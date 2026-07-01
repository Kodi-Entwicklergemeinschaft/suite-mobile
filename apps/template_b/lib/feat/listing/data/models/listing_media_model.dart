import 'package:network/network.dart';

/// Model for listing media (images, videos, etc.)
class ListingMediaModel extends BaseModel<ListingMediaModel> {
  final String? id;
  final String? type; // image, video, etc.
  final String? url;
  final String? altText;
  final String? caption;
  final int? order;
  final String? createdAt;

  ListingMediaModel({
    this.id,
    this.type,
    this.url,
    this.altText,
    this.caption,
    this.order,
    this.createdAt,
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
      createdAt: json['createdAt'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'url': url,
      'altText': altText,
      'caption': caption,
      'order': order,
      'createdAt': createdAt,
    };
  }

  ListingMediaModel copyWith({
    String? id,
    String? type,
    String? url,
    String? altText,
    String? caption,
    int? order,
    String? createdAt,
  }) {
    return ListingMediaModel(
      id: id ?? this.id,
      type: type ?? this.type,
      url: url ?? this.url,
      altText: altText ?? this.altText,
      caption: caption ?? this.caption,
      order: order ?? this.order,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
