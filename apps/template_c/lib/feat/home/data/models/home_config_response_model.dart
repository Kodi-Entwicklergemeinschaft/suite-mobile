import 'package:network/network.dart';
import 'home_config.dart';

/// Wrapper model for API response structure: {success, data, message, timestamp, path, statusCode}
/// Extracts HomeConfigModel from nested data.home array
class HomeConfigResponseModel extends BaseModel<HomeConfigResponseModel> {
  final bool success;
  final HomeConfigModel? homeConfig;
  final String? message;
  final String? timestamp;
  final String? path;
  final int? statusCode;

  HomeConfigResponseModel({
    this.success = false,
    this.homeConfig,
    this.message,
    this.timestamp,
    this.path,
    this.statusCode,
  });

  @override
  HomeConfigResponseModel fromJson(Map<String, dynamic> json) {
    // Extract home config from data.home array
    final data = json['data'] as Map<String, dynamic>?;
    final homeArray = data?['home'] as List?;

    HomeConfigModel? config;
    if (homeArray != null) {
      // Wrap array in {home: [...]} structure for HomeConfigModel
      final configJson = {'home': homeArray};
      config = HomeConfigModel(components: []).fromJson(configJson);
    }

    return HomeConfigResponseModel(
      success: json['success'] as bool? ?? false,
      homeConfig: config,
      message: json['message'] as String?,
      timestamp: json['timestamp'] as String?,
      path: json['path'] as String?,
      statusCode: json['statusCode'] as int?,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'success': success,
      if (homeConfig != null)
        'data': {'home': (homeConfig!.toJson()['home'] as List?) ?? []},
      if (message != null) 'message': message,
      if (timestamp != null) 'timestamp': timestamp,
      if (path != null) 'path': path,
      if (statusCode != null) 'statusCode': statusCode,
    };
  }
}
