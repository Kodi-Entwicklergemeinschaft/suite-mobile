import 'package:flutter/widgets.dart';
import 'package:dartz/dartz.dart';
import 'package:template_b/feat/bottom_navigation/model/request_model/bottom_navigation_config_request_model.dart';
import 'package:template_b/feat/bottom_navigation/model/response_model/bottom_navigation_config_response_model.dart';

abstract class BottomNavigationRepo {
  Future<Either<Exception, BottomNavigationConfigResponseModel>>
  getBottomNavigationConfig(BottomNavigationConfigRequestModel params);
}
