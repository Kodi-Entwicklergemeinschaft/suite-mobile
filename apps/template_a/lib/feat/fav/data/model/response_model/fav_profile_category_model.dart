import 'package:network/network.dart';

class FavProfileCategoryModel extends BaseModel<FavProfileCategoryModel> {
  final String? id;
  final String? slug;
  final String? title;
  final String? icon;
  final String? image;
  final String? titleBackgroundColor;

  FavProfileCategoryModel({
    this.id,
    this.slug,
    this.title,
    this.icon,
    this.image,
    this.titleBackgroundColor,
  });

  @override
  FavProfileCategoryModel fromJson(Map<String, dynamic> json) {
    return FavProfileCategoryModel(
      id: json['id'] as String?,
      slug: json['slug'] as String?,
      title: json['title'] as String?,
      icon: json['icon'] as String?,
      image: json['image'] as String?,
      titleBackgroundColor: json['titleBackgroundColor'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'slug': slug,
        'title': title,
        'icon': icon,
        'image': image,
        'titleBackgroundColor': titleBackgroundColor,
      };
}
