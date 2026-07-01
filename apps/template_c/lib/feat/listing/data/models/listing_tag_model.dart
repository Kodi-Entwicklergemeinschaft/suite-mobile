import 'package:network/network.dart';

/// Model for listing tags/categories
class ListingTagModel extends BaseModel<ListingTagModel> {
  final String? id;
  final String? name;
  final String? slug;
  final String? description;
  final String? color;

  ListingTagModel({
    this.id,
    this.name,
    this.slug,
    this.description,
    this.color,
  });

  @override
  ListingTagModel fromJson(Map<String, dynamic> json) {
    return ListingTagModel(
      id: json['id'] as String?,
      name: json['name'] as String?,
      slug: json['slug'] as String?,
      description: json['description'] as String?,
      color: json['color'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'description': description,
      'color': color,
    };
  }

  ListingTagModel copyWith({
    String? id,
    String? name,
    String? slug,
    String? description,
    String? color,
  }) {
    return ListingTagModel(
      id: id ?? this.id,
      name: name ?? this.name,
      slug: slug ?? this.slug,
      description: description ?? this.description,
      color: color ?? this.color,
    );
  }
}
