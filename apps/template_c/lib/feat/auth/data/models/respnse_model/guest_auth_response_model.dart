import 'package:network/network.dart';
import 'package:template_c/core/constant/common_enums.dart';

/// Response model for guest authentication
class GuestAuthResponseModel extends BaseModel<GuestAuthResponseModel> {
  final String? id;
  final UserRole? role;
  final String? deviceId;
  final String? accessToken;
  final String? refreshToken;
  final int? expiresIn;
  final bool? onboarded;
  final double? latitude;
  final double? longitude;
  final int? radius;
  final String? localityName;

  GuestAuthResponseModel({
    this.id,
    this.role,
    this.deviceId,
    this.accessToken,
    this.refreshToken,
    this.expiresIn,
    this.onboarded,
    this.latitude,
    this.longitude,
    this.radius,
    this.localityName,
  });

  @override
  GuestAuthResponseModel fromJson(Map<String, dynamic> json) {
    // Extract from 'data' field if it exists (API wrapper structure)
    final dataMap = json['data'] as Map<String, dynamic>? ?? json;

    return GuestAuthResponseModel(
      id: dataMap['id'] as String?,
      role: dataMap['role'] != null
          ? UserRole.fromValue(dataMap['role'] as String)
          : null,
      deviceId: dataMap['deviceId'] as String?,
      accessToken: dataMap['accessToken'] as String?,
      refreshToken: dataMap['refreshToken'] as String?,
      expiresIn: dataMap['expiresIn'] as int?,
      onboarded: dataMap['onboarded'] as bool?,
      latitude: (dataMap['latitude'] as num?)?.toDouble(),
      longitude: (dataMap['longitude'] as num?)?.toDouble(),
      radius: dataMap['radius'] as int?,
      localityName: dataMap['localityName'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'role': role?.value,
      'deviceId': deviceId,
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'expiresIn': expiresIn,
      'onboarded': onboarded,
      'latitude': latitude,
      'longitude': longitude,
      'radius': radius,
      'localityName': localityName,
    };
  }

  GuestAuthResponseModel copyWith({
    String? id,
    UserRole? role,
    String? deviceId,
    String? accessToken,
    String? refreshToken,
    int? expiresIn,
    bool? onboarded,
    double? latitude,
    double? longitude,
    int? radius,
    String? localityName,
  }) {
    return GuestAuthResponseModel(
      id: id ?? this.id,
      role: role ?? this.role,
      deviceId: deviceId ?? this.deviceId,
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      expiresIn: expiresIn ?? this.expiresIn,
      onboarded: onboarded ?? this.onboarded,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      radius: radius ?? this.radius,
      localityName: localityName ?? this.localityName,
    );
  }
}
