import 'package:network/network.dart';

/// Model representing user profile data
class ProfileModel extends BaseModel<ProfileModel> {
  final String? id;
  final String? username;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? avatarUrl;
  final String? website;
  final String? information;
  final bool? isActive;
  final String? role;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  // Wrapper fields from API response
  final bool? success;
  final String? message;
  final String? statusCode;
  final String? timestamp;
  final String? path;
  final int? events;
  final int? organizer;

  ProfileModel({
    this.id,
    this.username,
    this.firstName,
    this.lastName,
    this.email,
    this.avatarUrl,
    this.website,
    this.information,
    this.isActive,
    this.role,
    this.createdAt,
    this.updatedAt,
    this.success,
    this.message,
    this.statusCode,
    this.timestamp,
    this.path,
    this.events,
    this.organizer
  });

  @override
  ProfileModel fromJson(Map<String, dynamic> json) {
    // Extract from 'data' field if it exists (API wrapper structure)
    final dataMap = json['data'] as Map<String, dynamic>? ?? json;

    final favoritesMap = dataMap['favorites'] as Map<String, dynamic>?;

    return ProfileModel(
      id: dataMap['id'] as String?,
      username: dataMap['username'] as String?,
      firstName: dataMap['firstName'] as String?,
      lastName: dataMap['lastName'] as String?,
      email: dataMap['email'] as String?,
     avatarUrl: (dataMap['avatarUrl'] ?? dataMap['avatar']) as String?,
      website: dataMap['website'] as String?,
      information: dataMap['information'] as String?,
      isActive: dataMap['isActive'] as bool?,
      role: dataMap['role'] as String?,
      createdAt: dataMap['createdAt'] != null
          ? DateTime.parse(dataMap['createdAt'] as String).toLocal()
          : null,
      updatedAt: dataMap['updatedAt'] != null
          ? DateTime.parse(dataMap['updatedAt'] as String).toLocal()
          : null,
      success: json['success'] as bool?,
      message: json['message'] as String?,
      statusCode: json['statusCode']?.toString(),
      timestamp: json['timestamp'] as String?,
      path: json['path'] as String?,
      events: favoritesMap?['events'] as int?,
      organizer: favoritesMap?['organizer'] as int?,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'avatarUrl': avatarUrl,
      'website': website,
      'information': information,
      'isActive': isActive,
      'role': role,
      'createdAt': createdAt?.toUtc().toIso8601String(),
      'updatedAt': updatedAt?.toUtc().toIso8601String(),
      'success': success,
      'message': message,
      'statusCode': statusCode,
      'timestamp': timestamp,
      'path': path,
    };
  }

  ProfileModel copyWith({
    String? id,
    String? username,
    String? firstName,
    String? lastName,
    String? email,
    String? avatarUrl,
    String? website,
    String? information,
    bool? isActive,
    String? role,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? success,
    String? message,
    String? statusCode,
    String? timestamp,
    String? path,
    int? events,
    int? organizer,
  }) {
    return ProfileModel(
      id: id ?? this.id,
      username: username ?? this.username,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      website: website ?? this.website,
      information: information ?? this.information,
      isActive: isActive ?? this.isActive,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      success: success ?? this.success,
      message: message ?? this.message,
      statusCode: statusCode ?? this.statusCode,
      timestamp: timestamp ?? this.timestamp,
      path: path ?? this.path,
      events: events ?? this.events,
      organizer: organizer ?? this.organizer,
    );
  }
}
