import 'package:template_b/feat/sub_service/model/response/service_response_model.dart';

class DashboardScreenState {
  bool isLoading;
  List<ServiceResponseModel> serviceResponseModelList;
  DashboardScreenState(this.isLoading, this.serviceResponseModelList);

  DashboardScreenState copyWith({
    bool? isLoading,
    List<ServiceResponseModel>? serviceResponseModelList,
  }) {
    return DashboardScreenState(
      isLoading ?? this.isLoading,
      serviceResponseModelList ?? this.serviceResponseModelList,
    );
  }
}
