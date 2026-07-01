import 'package:network/network.dart';

class ContactResponseModel implements BaseModel<ContactResponseModel> {
  final bool? success;
  final String? message;
  final String? id;

  ContactResponseModel({
    this.success,
    this.message,
    this.id,
  });

  @override
  ContactResponseModel fromJson(Map<String, dynamic> json) {
    return ContactResponseModel(
      success: json['success'] as bool?,
      message: json['message'] as String?,
      id: json['id'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'id': id,
    };
  }
}