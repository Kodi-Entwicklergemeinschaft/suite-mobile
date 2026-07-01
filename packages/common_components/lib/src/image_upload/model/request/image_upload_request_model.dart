import 'package:network/network.dart';


class ImageUploadRequestModel implements BaseModel<ImageUploadRequestModel> {
  String? filePath;
  String? entityType;
  String? mediaType;

  ImageUploadRequestModel({
    this.filePath,
    this.entityType,
    this.mediaType,
  });

  @override
  ImageUploadRequestModel fromJson(Map<String, dynamic> json) {
    return ImageUploadRequestModel(
      entityType: json['entityType'] as String?,
      mediaType: json['mediaType'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'entityType': entityType,
      'mediaType': mediaType,
    };
  }
}
