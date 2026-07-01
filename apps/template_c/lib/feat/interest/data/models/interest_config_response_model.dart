import 'package:network/network.dart';

class InterestConfigResponseModel extends BaseModel<InterestConfigResponseModel> {
  final bool? success;
  final String? message;
  final List<InterestConfigCategories>? data;

  InterestConfigResponseModel({
    this.success,
    this.message,
    this.data,
  });

  @override
  InterestConfigResponseModel fromJson(Map<String, dynamic> json) {
    return InterestConfigResponseModel(
      success: json['success'],
      message: json['message'],
      data: (json['data'] as List?)
          ?.map((e) => InterestConfigCategories.fromJson(e))
          .toList(),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data?.map((e) => e.toJson()).toList(),
    };
  }
}

class InterestConfigCategories {
  final String? id;
  final String? slug;
  final String? title;
  final String? icon;
  final List<InterestCategoriesChildern>? children;

  InterestConfigCategories({
    this.id,
    this.slug,
    this.title,
    this.icon,
    this.children,
  });

  factory InterestConfigCategories.fromJson(Map<String, dynamic> json) {
    return InterestConfigCategories(
      id: json['id'],
      slug: json['slug'],
      title: json['title'],
      icon: json['icon'],
      children: (json['children'] as List?)
          ?.map((e) => InterestCategoriesChildern.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'slug': slug,
      'title': title,
      'icon': icon,
      'children': children?.map((e) => e.toJson()).toList(),
    };
  }
}

class InterestCategoriesChildern {
  final String? id;
  final String? slug;
  final String? title;
  final String? categoryId;
  final String? iconUrl;

  InterestCategoriesChildern({
    this.id,
    this.slug,
    this.title,
    this.categoryId,
    this.iconUrl,
  });

  factory InterestCategoriesChildern.fromJson(Map<String, dynamic> json) {
    return InterestCategoriesChildern(
      id: json['id'],
      slug: json['slug'],
      title: json['title'],
      categoryId: json['categoryId'],
      iconUrl: json['icon'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'slug': slug,
      'title': title,
      'categoryId': categoryId,
      'icon': iconUrl
    };
  }

  @override
  bool operator ==(Object other) =>
      other is InterestCategoriesChildern && other.id == id;

  @override
  int get hashCode => id.hashCode;
}