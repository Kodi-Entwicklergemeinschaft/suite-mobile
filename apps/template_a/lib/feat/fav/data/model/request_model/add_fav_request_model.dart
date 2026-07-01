import 'package:network/network.dart';

class AddFavRequestModel extends BaseModel<AddFavRequestModel> {
  final String id;

  AddFavRequestModel({required this.id});

  @override
  AddFavRequestModel fromJson(Map<String, dynamic> json) {
    return AddFavRequestModel(id: json['id'] as String);
  }

  @override
  Map<String, dynamic> toJson() => {'id': id};
}
