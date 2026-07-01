import 'package:flutter/cupertino.dart';

class LocationOnboardingParams {
  bool isSkip;
  void Function(BuildContext context) onConfirm;
  bool isSearchFilter;
  LocationOnboardingParams({required this.isSkip, required this.onConfirm, this.isSearchFilter = false});
}
