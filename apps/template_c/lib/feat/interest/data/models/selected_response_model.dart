import 'package:network/network.dart';

class SelectedResponseModel extends BaseModel<SelectedResponseModel> {
  final bool? success;
  final String? message;
  final SelectedData? data;

  SelectedResponseModel({
    this.success,
    this.message,
    this.data,
  });

  @override
  SelectedResponseModel fromJson(Map<String, dynamic> json) {
    return SelectedResponseModel(
      success: json['success'],
      message: json['message'],
      data: json['data'] != null
          ? SelectedData.fromJson(json['data'])
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data?.toJson(),
    };
  }
}

class SelectedData {
  final List<String>? subcategoryIds;

  SelectedData({
    this.subcategoryIds,
  });

  factory SelectedData.fromJson(Map<String, dynamic> json) {
    List<String> flattenIds(List<dynamic>? raw) {
      if (raw == null) return const [];
      final result = <String>[];
      for (final entry in raw) {
        final value = entry.toString();
        if (value.isEmpty) continue;
        final parts = value.split(',');
        for (final part in parts) {
          final trimmed = part.trim();
          if (trimmed.isNotEmpty) {
            result.add(trimmed);
          }
        }
      }
      return result;
    }

    return SelectedData(
      subcategoryIds: flattenIds(json['subcategoryIds'] as List?),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'subcategoryIds': subcategoryIds,
    };
  }
}
