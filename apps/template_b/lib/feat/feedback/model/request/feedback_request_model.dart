import 'package:network/network.dart';

class FeedbackRequestModel implements BaseModel<FeedbackRequestModel> {
  String email;
  String information;
  FeedbackRequestModel({this.email = '', this.information = ''});
  @override
  FeedbackRequestModel fromJson(Map<String, dynamic> json) {
    return FeedbackRequestModel(
      email: json['email'] ?? '',
      information: json['information'] ?? '',
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {'email': email, 'information': information};
  }
}
