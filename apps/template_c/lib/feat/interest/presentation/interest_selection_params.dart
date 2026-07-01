import 'package:flutter/cupertino.dart';

class InterestSelectionParams {
  bool isSkip;
  void Function(BuildContext context) onConfirm;
  InterestSelectionParams({required this.isSkip, required this.onConfirm});
}
