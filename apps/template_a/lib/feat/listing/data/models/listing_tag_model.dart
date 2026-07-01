import 'package:network/network.dart';

class ListingTagModel implements BaseModel {
  final String? id;
  final String? name;
  final String? slug;
  final String? color;

  ListingTagModel({this.id, this.name, this.slug, this.color});

  @override
  ListingTagModel fromJson(Map<String, dynamic> json) {
    return ListingTagModel(
      id: json['id'] as String?,
      name: json['name'] as String?,
      slug: json['slug'] as String?,
      color: json['color'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'slug': slug,
    'color': color,
  };
}
