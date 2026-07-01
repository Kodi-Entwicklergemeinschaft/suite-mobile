import 'package:network/network.dart';

class FavCategoryModel extends BaseModel<FavCategoryModel> {
  final String? slug;
  final String? title;
  final String? imageUrl;
  final String? headerBackgroundColor;

  FavCategoryModel({this.slug, this.title, this.imageUrl, this.headerBackgroundColor});

  @override
  FavCategoryModel fromJson(Map<String, dynamic> json) {
    return FavCategoryModel(
      slug: json['slug'] as String?,
      title: json['title'] as String?,
      imageUrl: json['imageUrl'] as String?,
      headerBackgroundColor: json['headerBackgroundColor'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'slug': slug,
    'title': title,
    'imageUrl': imageUrl,
    'headerBackgroundColor': headerBackgroundColor,
  };
}
