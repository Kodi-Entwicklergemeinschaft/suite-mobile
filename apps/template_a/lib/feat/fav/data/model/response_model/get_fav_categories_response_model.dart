import 'package:network/network.dart';
import 'package:template_a/feat/fav/data/model/response_model/fav_profile_category_model.dart';

class GetFavCategoriesResponseModel
    extends BaseModel<GetFavCategoriesResponseModel> {
  final bool success;
  final List<FavProfileCategoryModel>? data;
  final String? message;

  GetFavCategoriesResponseModel({
    this.success = false,
    this.data,
    this.message,
  });

  @override
  GetFavCategoriesResponseModel fromJson(Map<String, dynamic> json) {
    final rawData = (json['data'] as List<dynamic>?) ?? [];
    return GetFavCategoriesResponseModel(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String?,
      data: rawData
          .map((e) =>
              FavProfileCategoryModel().fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'success': success,
        'message': message,
        'data': data?.map((e) => e.toJson()).toList(),
      };
}
