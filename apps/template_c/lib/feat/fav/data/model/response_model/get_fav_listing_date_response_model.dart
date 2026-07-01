import 'package:network/network.dart';

class GetFavListingDateResponseModel
    implements BaseModel<GetFavListingDateResponseModel> {
  bool? success;
  GetFavListingDateDataModel? data;
  String? message;
  String? timestamp;
  String? path;
  int? statusCode;

  // Constructor for internal use
  GetFavListingDateResponseModel({
    this.success,
    this.data,
    this.message,
    this.timestamp,
    this.path,
    this.statusCode,
  });

  @override
  GetFavListingDateResponseModel fromJson(Map<String, dynamic> json) {
    return GetFavListingDateResponseModel(
      success: json['success'],
      data: json['data'] != null ? GetFavListingDateDataModel.fromJson(json['data']) : null,
      message: json['message'],
      timestamp: json['timestamp'],
      path: json['path'],
      statusCode: json['statusCode'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data?.toJson(),
      'message': message,
      'timestamp': timestamp,
      'path': path,
      'statusCode': statusCode,
    };
  }
}

class GetFavListingDateDataModel {
  List<String>? dates;

  GetFavListingDateDataModel({this.dates});

  factory GetFavListingDateDataModel.fromJson(Map<String, dynamic> json) {
    return GetFavListingDateDataModel(
      dates: json['dates'] != null ? List<String>.from(json['dates']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {'dates': dates};
  }
}
