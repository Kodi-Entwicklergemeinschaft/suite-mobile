import 'package:network/network.dart';

class QuickFilterResponseModel implements BaseModel {
  final bool? success;
  final int? statusCode;
  final String? message;
  final List<FilterGroup> groups;

  QuickFilterResponseModel({
    this.success,
    this.statusCode,
    this.message,
    this.groups = const [],
  });

  @override
  QuickFilterResponseModel fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>?;
    return QuickFilterResponseModel(
      success: json['success'] as bool?,
      statusCode: json['statusCode'] as int?,
      message: json['message'] as String?,
      groups: (data?['groups'] as List? ?? [])
          .map((e) => FilterGroup.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'success': success,
        'statusCode': statusCode,
        'message': message,
      };
}

class FilterGroup {
  final String? name;
  final List<FilterHeading> headings;

  FilterGroup({this.name, this.headings = const []});

  // API response: { "heading": "...", "group": null, "filters": [...] }
  factory FilterGroup.fromJson(Map<String, dynamic> json) {
    final filters = (json['filters'] as List? ?? [])
        .map((e) => FilterItem.fromJson(e as Map<String, dynamic>))
        .toList();
    return FilterGroup(
      name: json['heading'] as String?,
      headings: [FilterHeading(filters: filters)],
    );
  }
}

class FilterHeading {
  final String? name;
  final List<FilterItem> filters;

  FilterHeading({this.name, this.filters = const []});

  factory FilterHeading.fromJson(Map<String, dynamic> json) => FilterHeading(
        name: json['name'] as String?,
        filters: (json['filters'] as List? ?? [])
            .map((e) => FilterItem.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class FilterItem {
  final String? id;
  final String? value;
  final String? label;
  final String? displayName;
  final int? displayOrder;

  FilterItem({
    this.id,
    this.value,
    this.label,
    this.displayName,
    this.displayOrder,
  });

  factory FilterItem.fromJson(Map<String, dynamic> json) {
    final filter = json['filter'] as Map<String, dynamic>?;
    return FilterItem(
      id: json['id'] as String?,
      value: filter?['value'] as String?,
      label: filter?['label'] as String?,
      displayName: json['displayName'] as String?,
      displayOrder: json['displayOrder'] as int?,
    );
  }

  String get displayLabel => displayName ?? label ?? value ?? '';
}
