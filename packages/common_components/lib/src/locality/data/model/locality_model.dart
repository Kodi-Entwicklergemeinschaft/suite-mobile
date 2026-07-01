class LocalityModel {
  final String id;
  final String name;
  final String? code;
  final String? image;
  final int? sortOrder;

  const LocalityModel({
    required this.id,
    required this.name,
    this.code,
    this.image,
    this.sortOrder,
  });

  factory LocalityModel.fromJson(Map<String, dynamic> json) {
    return LocalityModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      code: json['code']?.toString(),
      image: json['image']?.toString(),
      sortOrder: json['sortOrder'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        if (code != null) 'code': code,
        if (image != null) 'image': image,
        if (sortOrder != null) 'sortOrder': sortOrder,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is LocalityModel && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
