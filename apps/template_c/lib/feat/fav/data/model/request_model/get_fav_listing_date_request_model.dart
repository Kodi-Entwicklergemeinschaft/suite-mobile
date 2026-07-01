import 'package:network/network.dart';

class GetFavListingDateRequestModel
    implements BaseModel<GetFavListingDateRequestModel> {
  DateTime startDate;
  DateTime endDate;

  GetFavListingDateRequestModel({
    required this.startDate,
    required this.endDate,
  });
  @override
  GetFavListingDateRequestModel fromJson(Map<String, dynamic> json) {
    // TODO: implement fromJson
    throw UnimplementedError();
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'startDate': startDate.toUtc().toIso8601String(),
      'endDate': endDate.toUtc().toIso8601String(),
    };
  }
}
