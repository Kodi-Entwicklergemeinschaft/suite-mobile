import 'package:network/network.dart';

/// Company profile model for random companies endpoint
/// Maps to: /api/business/job-matching/companies/random
class CompanyProfileModel {
  final String id;
  final String? name; // Company name
  final String? image; // Company logo URL
  final String? companyProfileUrl; // Link to company profile

  CompanyProfileModel({
    required this.id,
    this.name,
    this.image,
    this.companyProfileUrl,
  });

  factory CompanyProfileModel.fromJson(Map<String, dynamic> json) {
    return CompanyProfileModel(
      id: json['id'] as String,
      name: json['name'] as String?,
      image: json['image'] as String?,
      companyProfileUrl: json['companyProfileUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image': image,
      'companyProfileUrl': companyProfileUrl,
    };
  }
}

/// Response wrapper for new API format: /api/business/job-matching/companies/random
/// Returns companies as direct array in 'data' field
class CompanyProfileResponseModel implements BaseModel {
  final bool success;
  final List<CompanyProfileModel> companies;
  final String? message;

  CompanyProfileResponseModel({
    this.success = false,
    this.companies = const [],
    this.message,
  });

  @override
  CompanyProfileResponseModel fromJson(Map<String, dynamic> json) {
    final companiesList = (json['data'] as List? ?? [])
        .map((item) => CompanyProfileModel.fromJson(item as Map<String, dynamic>))
        .toList();

    return CompanyProfileResponseModel(
      success: json['success'] as bool? ?? false,
      companies: companiesList,
      message: json['message'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': companies,
      'message': message,
    };
  }
}
