import 'package:network/network.dart';

class OrganizerModel extends BaseModel<OrganizerModel> {
  final String? id;
  final String? username;
  final String? displayName;
  final String? avatar;
  final String? summary;
  final bool? isFollowing;
  final int? followerCount;

  OrganizerModel({
    this.id,
    this.username,
    this.displayName,
    this.avatar,
    this.summary,
    this.isFollowing,
    this.followerCount,
  });

  @override
  OrganizerModel fromJson(Map<String, dynamic> json) {
    return OrganizerModel(
      id: json['id'] as String?,
      username: json['username'] as String?,
      displayName: json['displayName'] as String?,
      avatar: json['avatar'] as String?,
      summary: json['summary'] as String?,
      isFollowing: json['isFollowing'] as bool?,
      followerCount: json['followerCount'] as int?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'displayName': displayName,
        'avatar': avatar,
        'summary': summary,
        'isFollowing': isFollowing,
        'followerCount': followerCount,
      };

  OrganizerModel copyWith({
    String? id,
    String? username,
    String? displayName,
    String? avatar,
    String? summary,
    bool? isFollowing,
    int? followerCount,
  }) =>
      OrganizerModel(
        id: id ?? this.id,
        username: username ?? this.username,
        displayName: displayName ?? this.displayName,
        avatar: avatar ?? this.avatar,
        summary: summary ?? this.summary,
        isFollowing: isFollowing ?? this.isFollowing,
        followerCount: followerCount ?? this.followerCount,
      );
}
