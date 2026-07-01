import 'package:network/network.dart';
import 'locality_model.dart';

class GetLocalitiesResponseModel extends BaseModel<GetLocalitiesResponseModel> {
  final List<LocalityModel> localities;

  GetLocalitiesResponseModel({this.localities = const []});

  @override
  GetLocalitiesResponseModel fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final raw = data is Map ? data['localities'] : data;
    final list = raw is List ? raw : <dynamic>[];
    return GetLocalitiesResponseModel(
      localities: list
          .map((e) => LocalityModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  Map<String, dynamic> toJson() => {};
}
