import 'package:network/network.dart';

class ImageDeleteRequestModel implements BaseModel<ImageDeleteRequestModel> {
  final String? mediaUrl;
  final String? entityType;

  ImageDeleteRequestModel({
    this.mediaUrl,
    this.entityType,
  });

  @override
  ImageDeleteRequestModel fromJson(Map<String, dynamic> json) {
    return ImageDeleteRequestModel(
      mediaUrl: json['mediaUrl'] as String?,
      entityType: json['entityType'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'mediaUrl': mediaUrl,
      'entityType': entityType,
    };
  }
}
