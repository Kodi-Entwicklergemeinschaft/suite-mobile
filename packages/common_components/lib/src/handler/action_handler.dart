import 'package:flutter/material.dart';

abstract class ActionHandler<T> {
  void executeAction(BuildContext context, T data, {String? title});
}
