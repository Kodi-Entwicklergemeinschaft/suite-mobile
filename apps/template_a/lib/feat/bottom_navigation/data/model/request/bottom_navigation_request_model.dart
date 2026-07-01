import 'package:network/network.dart';

class BottomNavigationRequestModel
    implements BaseModel<BottomNavigationRequestModel> {
  @override
  BottomNavigationRequestModel fromJson(Map<String, dynamic> json) {
    return BottomNavigationRequestModel();
  }

  @override
  Map<String, dynamic> toJson() {
    return {};
  }
}
