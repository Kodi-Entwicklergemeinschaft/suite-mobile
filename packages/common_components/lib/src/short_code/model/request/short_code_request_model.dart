import 'package:network/network.dart';

class ShortCodeRequestModel implements BaseModel<ShortCodeRequestModel> {
  DeviceInfo? deviceInfo;
  Metadata? metadata;
  int? ttlSeconds;

  ShortCodeRequestModel({
    this.deviceInfo,
    this.metadata,
    this.ttlSeconds,
  });

  @override
  ShortCodeRequestModel fromJson(Map<String, dynamic> json) {
    return ShortCodeRequestModel(
      deviceInfo: json['deviceInfo'] != null 
          ? DeviceInfo().fromJson(json['deviceInfo']) 
          : null,
      metadata: json['metadata'] != null 
          ? Metadata().fromJson(json['metadata']) 
          : null,
      ttlSeconds: json['ttlSeconds'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'deviceInfo': deviceInfo?.toJson(),
      'metadata': metadata?.toJson(),
      'ttlSeconds': ttlSeconds,
    };
  }
}

class DeviceInfo implements BaseModel<DeviceInfo> {
  String? userAgent;
  String? platform;

  DeviceInfo({this.userAgent, this.platform});

  @override
  DeviceInfo fromJson(Map<String, dynamic> json) {
    return DeviceInfo(
      userAgent: json['userAgent'],
      platform: json['platform'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'userAgent': userAgent,
      'platform': platform,
    };
  }
}

class Metadata implements BaseModel<Metadata> {
  String? purpose;
  String? appVersion;

  Metadata({this.purpose, this.appVersion});

  @override
  Metadata fromJson(Map<String, dynamic> json) {
    return Metadata(
      purpose: json['purpose'],
      appVersion: json['appVersion'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'purpose': purpose,
      'appVersion': appVersion,
    };
  }
}