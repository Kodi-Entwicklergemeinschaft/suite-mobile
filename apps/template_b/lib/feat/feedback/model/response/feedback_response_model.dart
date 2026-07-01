import 'package:network/network.dart';

class FeedbackResponseModel implements BaseModel<FeedbackResponseModel> {
  String? message;
  bool? success;
  String? id;

  FeedbackResponseModel({this.message, this.success, this.id});

  @override
  FeedbackResponseModel fromJson(Map<String, dynamic> json) {
    return FeedbackResponseModel(
      message: json['message'] ?? '',
      success: json['success'] ?? false,
      id: json['id'] ?? '',
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {'message': message, 'success': success, 'id': id};
  }
}
