import 'package:network/network.dart';
import 'package:template_c/core/constant/common_enums.dart';

/// Model representing user data from login response
class UserModel extends BaseModel<UserModel> {
  final String? id;
  final String? email;
  final UserRole? role;
  final bool? onboarded;
  final double? latitude;
  final double? longitude;
  final int? radius;
  final String? localityName;
  final String? username;

  UserModel({
    this.id,
    this.email,
    this.role,
    this.onboarded,
    this.latitude,
    this.longitude,
    this.radius,
    this.localityName,
    this.username,
  });

  @override
  UserModel fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String?,
      email: json['email'] as String?,
      role: json['role'] != null ? UserRole.fromValue(json['role'] as String) : null,
      onboarded: json['onboarded'] as bool?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      radius: json['radius'] as int?,
      localityName: json['localityName'] as String?,
      username: json['username'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'role': role?.value,
      'onboarded': onboarded,
      'latitude': latitude,
      'longitude': longitude,
      'radius': radius,
      'localityName': localityName,
      'username': username,
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    UserRole? role,
    bool? onboarded,
    double? latitude,
    double? longitude,
    int? radius,
    String? localityName,
    String? username,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      role: role ?? this.role,
      onboarded: onboarded ?? this.onboarded,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      radius: radius ?? this.radius,
      localityName: localityName ?? this.localityName,
      username: username?? this.username,
    );
  }
}

/// Model representing login response data from API
class LoginResponseModel extends BaseModel<LoginResponseModel> {
  final String? accessToken;
  final String? refreshToken;
  final int? expiresIn;
  final UserModel? user;
  final bool? success;
  final String? message;
  final String? statusCode;
  final String? timestamp;
  final String? path;

  LoginResponseModel({
    this.accessToken,
    this.refreshToken,
    this.expiresIn,
    this.user,
    this.success,
    this.message,
    this.statusCode,
    this.timestamp,
    this.path,
  });

  @override
  LoginResponseModel fromJson(Map<String, dynamic> json) {
    // Extract from 'data' field if it exists (API wrapper structure)
    final dataMap = json['data'] as Map<String, dynamic>? ?? json;

    return LoginResponseModel(
      accessToken: dataMap['accessToken'] as String?,
      refreshToken: dataMap['refreshToken'] as String?,
      expiresIn: dataMap['expiresIn'] as int?,
      user: dataMap['user'] != null
          ? UserModel().fromJson(dataMap['user'] as Map<String, dynamic>)
          : null,
      success: json['success'] as bool?,
      message: json['message'] as String?,
      statusCode: json['statusCode']?.toString(),
      timestamp: json['timestamp'] as String?,
      path: json['path'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'expiresIn': expiresIn,
      'user': user?.toJson(),
      'success': success,
      'message': message,
      'statusCode': statusCode,
      'timestamp': timestamp,
      'path': path,
    };
  }

  LoginResponseModel copyWith({
    String? accessToken,
    String? refreshToken,
    int? expiresIn,
    UserModel? user,
    bool? success,
    String? message,
    String? statusCode,
    String? timestamp,
    String? path,
  }) {
    return LoginResponseModel(
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      expiresIn: expiresIn ?? this.expiresIn,
      user: user ?? this.user,
      success: success ?? this.success,
      message: message ?? this.message,
      statusCode: statusCode ?? this.statusCode,
      timestamp: timestamp ?? this.timestamp,
      path: path ?? this.path,
    );
  }
}
