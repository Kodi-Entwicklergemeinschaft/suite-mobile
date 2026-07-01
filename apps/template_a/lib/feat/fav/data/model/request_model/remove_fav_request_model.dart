import 'package:network/network.dart';

class RemoveFavRequestModel extends BaseModel<RemoveFavRequestModel> {
  final String id;

  RemoveFavRequestModel({required this.id});

  @override
  RemoveFavRequestModel fromJson(Map<String, dynamic> json) {
    return RemoveFavRequestModel(id: json['id'] as String);
  }

  @override
  Map<String, dynamic> toJson() => {'id': id};
}
