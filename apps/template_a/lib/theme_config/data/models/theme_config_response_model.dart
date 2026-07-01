import 'package:network/network.dart';
import 'package:theme/theme.dart';

class ThemeConfigResponseModel implements BaseModel<ThemeConfigResponseModel> {
  final AppTheme? data;

  ThemeConfigResponseModel({this.data});

  @override
  ThemeConfigResponseModel fromJson(Map<String, dynamic> json) {
    return ThemeConfigResponseModel(
      data: json['data'] != null
          ? AppTheme.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {'data': data?.toJson()};
  }
}
