import 'package:network/network.dart';

class BottomNavigationConfigRequestModel
    implements BaseModel<BottomNavigationConfigRequestModel> {
  @override
  BottomNavigationConfigRequestModel fromJson(Map<String, dynamic> json) {
    return BottomNavigationConfigRequestModel();
  }

  @override
  Map<String, dynamic> toJson() {
    return {};
  }
}
