import 'package:network/network.dart';
import 'package:template_c/feat/listing/data/models/listing_model.dart';

class OrganizerDetailModel extends BaseModel<OrganizerDetailModel> {
  final String? id;
  final String? username;
  final String? displayName;
  final String? avatar;
  final String? summary;
  final String? website;
  final String? address;
  final bool? isFollowing;
  final int? followerCount;
  final List<ListingModel>? upcomingEvents;
  final int? upcomingEventsTotal;
  final bool? eventsHasMore;
  final int? eventsCurrentPage;

  OrganizerDetailModel({
    this.id,
    this.username,
    this.displayName,
    this.avatar,
    this.summary,
    this.website,
    this.address,
    this.isFollowing,
    this.followerCount,
    this.upcomingEvents,
    this.upcomingEventsTotal,
    this.eventsHasMore,
    this.eventsCurrentPage,
  });

  @override
  OrganizerDetailModel fromJson(Map<String, dynamic> json) {
    final data = (json['data'] as Map<String, dynamic>?) ?? json;
    final eventsMap = data['upcomingEvents'] as Map<String, dynamic>?;
    final eventItems = (eventsMap?['items'] as List<dynamic>?)
        ?.map((e) => ListingModel().fromJson(e as Map<String, dynamic>))
        .toList();
    return OrganizerDetailModel(
      id: data['id'] as String?,
      username: data['username'] as String?,
      displayName: data['displayName'] as String?,
      avatar: data['avatar'] as String?,
      summary: data['summary'] as String?,
      website: data['website'] as String?,
      address: data['address'] as String?,
      isFollowing: data['isFollowing'] as bool?,
      followerCount: data['followerCount'] as int?,
      upcomingEvents: eventItems,
      upcomingEventsTotal: eventsMap?['total'] as int?,
      eventsHasMore: (eventsMap?['meta'] as Map<String, dynamic>?)?['hasNextPage'] as bool?,
      eventsCurrentPage: (eventsMap?['meta'] as Map<String, dynamic>?)?['page'] as int?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'displayName': displayName,
        'avatar': avatar,
        'summary': summary,
        'website': website,
        'address': address,
        'isFollowing': isFollowing,
        'followerCount': followerCount,
        'upcomingEventsTotal': upcomingEventsTotal,
      };

  OrganizerDetailModel copyWith({
    String? id,
    String? username,
    String? displayName,
    String? avatar,
    String? summary,
    String? website,
    String? address,
    bool? isFollowing,
    int? followerCount,
    List<ListingModel>? upcomingEvents,
    int? upcomingEventsTotal,
    bool? eventsHasMore,
    int? eventsCurrentPage,
  }) =>
      OrganizerDetailModel(
        id: id ?? this.id,
        username: username ?? this.username,
        displayName: displayName ?? this.displayName,
        avatar: avatar ?? this.avatar,
        summary: summary ?? this.summary,
        website: website ?? this.website,
        address: address ?? this.address,
        isFollowing: isFollowing ?? this.isFollowing,
        followerCount: followerCount ?? this.followerCount,
        upcomingEvents: upcomingEvents ?? this.upcomingEvents,
        upcomingEventsTotal: upcomingEventsTotal ?? this.upcomingEventsTotal,
        eventsHasMore: eventsHasMore ?? this.eventsHasMore,
        eventsCurrentPage: eventsCurrentPage ?? this.eventsCurrentPage,
      );
}
