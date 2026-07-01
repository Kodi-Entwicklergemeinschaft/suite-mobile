import 'package:network/network.dart';

class DashboardConfigRequestModel
    implements BaseModel<DashboardConfigRequestModel> {
  DashboardConfigRequestModel();
  @override
  DashboardConfigRequestModel fromJson(Map<String, dynamic> json) {
    return DashboardConfigRequestModel();
  }

  @override
  Map<String, dynamic> toJson() {
    return {};
  }
}
