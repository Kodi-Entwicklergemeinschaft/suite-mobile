import 'package:network/network.dart';
import 'package:template_b/feat/sub_service/model/response/service_response_model.dart';

class DashboardConfigResponseModel
    implements BaseModel<DashboardConfigResponseModel> {
  final List<ServiceResponseModel> serviceResponseModelList;

  DashboardConfigResponseModel({this.serviceResponseModelList = const []});

  @override
  DashboardConfigResponseModel fromJson(Map<String, dynamic> json) {
    return DashboardConfigResponseModel(
      serviceResponseModelList:
          (json['data']['dashboard'] as List<dynamic>?)
              ?.map((e) => ServiceResponseModel().fromJson(e))
              .toList() ??
          [],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'dashboard': serviceResponseModelList.map((e) => e.toJson()).toList(),
    };
  }
}
