import 'package:network/network.dart';
import 'package:template_c/feat/organizer/data/models/organizer_model.dart';

class OrganizerRecommendationsResponseModel
    extends BaseModel<OrganizerRecommendationsResponseModel> {
  final List<OrganizerModel>? items;
  final bool? success;
  final String? message;

  OrganizerRecommendationsResponseModel({
    this.items,
    this.success,
    this.message,
  });

  @override
  OrganizerRecommendationsResponseModel fromJson(Map<String, dynamic> json) {
    final dataList = json['data'] as List<dynamic>?;
    return OrganizerRecommendationsResponseModel(
      items: dataList
          ?.map((e) => OrganizerModel().fromJson(e as Map<String, dynamic>))
          .toList(),
      success: json['success'] as bool?,
      message: json['message'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'items': items?.map((e) => e.toJson()).toList(),
        'success': success,
        'message': message,
      };
}
