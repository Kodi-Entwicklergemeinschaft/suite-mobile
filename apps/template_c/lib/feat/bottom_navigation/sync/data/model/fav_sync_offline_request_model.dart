import 'package:network/network.dart';

class FavSyncOfflineRequestModel extends BaseModel<FavSyncOfflineRequestModel> {
  final List<String> removeFavorites;

  FavSyncOfflineRequestModel({required this.removeFavorites});

  @override
  FavSyncOfflineRequestModel fromJson(Map<String, dynamic> json) {
    return FavSyncOfflineRequestModel(
      removeFavorites: List<String>.from(json['REMOVE_FAVORITES'] ?? []),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'REMOVE_FAVORITES': removeFavorites,
    };
  }
}
