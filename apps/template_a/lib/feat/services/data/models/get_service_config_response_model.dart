import 'package:network/network.dart';
import 'service_response_model.dart';

class GetServiceConfigResponseModel implements BaseModel {
  bool? success;
  ServiceConfigDataModel? data;
  String? message;
  String? timestamp;

  GetServiceConfigResponseModel({this.success, this.data, this.message, this.timestamp});

  @override
  GetServiceConfigResponseModel fromJson(Map<String, dynamic> json) {
    return GetServiceConfigResponseModel(
      success: json['success'],
      message: json['message'],
      timestamp: json['timestamp'],
      data: json['data'] != null 
          ? ServiceConfigDataModel().fromJson(json['data']) 
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'timestamp': timestamp,
      'data': data?.toJson(),
    };
  }
}

class ServiceConfigDataModel implements BaseModel<ServiceConfigDataModel> {
  List<ServiceResponseModel>? items;
  ServiceConfigMetaModel? meta;

  ServiceConfigDataModel({this.items, this.meta});

  @override
  ServiceConfigDataModel fromJson(Map<String, dynamic> json) {
    return ServiceConfigDataModel(
      items: json['items'] != null
          ? (json['items'] as List)
              .map((i) => ServiceResponseModel().fromJson(i))
              .toList()
          : null,
      meta: json['meta'] != null 
          ? ServiceConfigMetaModel().fromJson(json['meta']) 
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'items': items?.map((v) => v.toJson()).toList(),
      'meta': meta?.toJson(),
    };
  }
}

class ServiceConfigMetaModel implements BaseModel<ServiceConfigMetaModel> {
  int? page;
  int? limit;
  int? total;
  int? totalPages;
  bool? hasNextPage;
  bool? hasPreviousPage;

  ServiceConfigMetaModel({
    this.page,
    this.limit,
    this.total,
    this.totalPages,
    this.hasNextPage,
    this.hasPreviousPage,
  });

  @override
  ServiceConfigMetaModel fromJson(Map<String, dynamic> json) {
    return ServiceConfigMetaModel(
      page: json['page'],
      limit: json['limit'],
      total: json['total'],
      totalPages: json['totalPages'],
      hasNextPage: json['hasNextPage'],
      hasPreviousPage: json['hasPreviousPage'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'page': page,
      'limit': limit,
      'total': total,
      'totalPages': totalPages,
      'hasNextPage': hasNextPage,
      'hasPreviousPage': hasPreviousPage,
    };
  }
}
