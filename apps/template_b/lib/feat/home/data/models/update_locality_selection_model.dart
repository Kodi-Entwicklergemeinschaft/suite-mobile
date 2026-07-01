import 'package:network/network.dart';

/// Request model for POST /api/localities/selection endpoint
class UpdateLocalitySelectionModel implements BaseModel {
  final List<String> localities;

  UpdateLocalitySelectionModel({
    required this.localities,
  });

  @override
  UpdateLocalitySelectionModel fromJson(Map<String, dynamic> json) {
    final localitiesList = json['localities'] as List? ?? [];
    return UpdateLocalitySelectionModel(
      localities: localitiesList.cast<String>(),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'localities': localities,
    };
  }
}
