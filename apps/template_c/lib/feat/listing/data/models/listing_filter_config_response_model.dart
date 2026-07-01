import 'package:network/network.dart';

/// Single filter option item
class FilterOptionItem {
  final String name;
  final String? localityId;
  final DateTime? startDate;
  final DateTime? endDate;

  FilterOptionItem({
    required this.name,
    this.localityId,
    this.startDate,
    this.endDate,
  });

  factory FilterOptionItem.fromJson(Map<String, dynamic> json) {
    return FilterOptionItem(
      name: json['name'] as String? ?? '',
      localityId: json['localityId'] as String?,
      startDate: json['startDate'] != null
          ? DateTime.parse(json['startDate'] as String).toLocal()
          : null,
      endDate: json['endDate'] != null
          ? DateTime.parse(json['endDate'] as String).toLocal()
          : null,
    );
  }
}

/// Single filter section
class FilterSectionData {
  final String label;
  final bool isMultiSelect;
  final List<FilterOptionItem> items;

  FilterSectionData({
    required this.label,
    required this.isMultiSelect,
    required this.items,
  });

  factory FilterSectionData.fromJson(Map<String, dynamic> json) {
    final items = (json['items'] as List?)
        ?.map((item) => FilterOptionItem.fromJson(item as Map<String, dynamic>))
        .toList() ?? [];

    return FilterSectionData(
      label: json['label'] as String? ?? '',
      isMultiSelect: json['isMultiSelect'] as bool? ?? false,
      items: items,
    );
  }
}

/// Main filter config data response
class FilterConfigData {
  final FilterSectionData? dateRange;
  final FilterSectionData? locality;

  FilterConfigData({
    this.dateRange,
    this.locality,
  });

  factory FilterConfigData.fromJson(Map<String, dynamic> json) {
    return FilterConfigData(
      dateRange: json['dateRange'] != null
          ? FilterSectionData.fromJson(json['dateRange'] as Map<String, dynamic>)
          : null,
      locality: json['locality'] != null
          ? FilterSectionData.fromJson(json['locality'] as Map<String, dynamic>)
          : null,
    );
  }
}

/// Full response from /api/listings/filters/{categorySlug}
class ListingFilterConfigResponseModel implements BaseModel {
  final bool success;
  final FilterConfigData? data;
  final String? message;

  ListingFilterConfigResponseModel({
    this.success = false,
    this.data,
    this.message,
  });

  @override
  ListingFilterConfigResponseModel fromJson(Map<String, dynamic> json) {
    return ListingFilterConfigResponseModel(
      success: json['success'] as bool? ?? false,
      data: json['data'] != null
          ? FilterConfigData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
      message: json['message'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data,
      'message': message,
    };
  }
}
