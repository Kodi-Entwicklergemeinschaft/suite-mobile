import 'package:dartz/dartz.dart';
import 'package:template_a/feat/auth/data/models/forgot_password_request_model.dart';
import 'package:template_a/feat/auth/data/models/forgot_password_response_model.dart';
import 'package:template_a/feat/auth/data/models/login_request_model.dart';
import 'package:template_a/feat/auth/data/models/login_response_model.dart';
import 'package:template_a/feat/auth/data/models/register_request_model.dart';
import 'package:template_a/feat/auth/data/models/register_response_model.dart';

abstract class AuthRepository {
  Future<Either<Exception, LoginResponseModel>> login(LoginRequestModel request);
  Future<Either<Exception, LoginResponseModel>> guestLogin({required String deviceId});
  Future<Either<Exception, RegisterResponseModel>> register(RegisterRequestModel request);
  Future<Either<Exception, ForgotPasswordResponseModel>> forgotPassword(ForgotPasswordRequestModel request);
}
