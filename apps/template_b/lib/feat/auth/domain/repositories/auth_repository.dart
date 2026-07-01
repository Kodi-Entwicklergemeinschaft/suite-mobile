import 'package:network/network.dart';
import '../../data/models/request_model/login_request_model.dart';
import '../../data/models/register_request_model.dart';
import '../../data/models/respnse_model/login_response_model.dart';
import '../../data/models/respnse_model/register_response_model.dart';
import '../../data/models/request_model/forgot_password_request_model.dart';
import '../../data/models/respnse_model/forgot_password_response_model.dart';
import '../../data/models/request_model/guest_auth_request_model.dart';
import '../../data/models/respnse_model/guest_auth_response_model.dart';
import '../../data/models/request_model/guest_register_request_model.dart';
import '../../data/models/respnse_model/guest_register_response_model.dart';
import '../../data/models/request_model/change_password_request_model.dart';
import '../../data/models/respnse_model/change_password_response_model.dart';

/// Abstract repository for authentication operations
abstract class AuthRepository {
  /// Login user with email and password
  Future<Either<Exception, LoginResponseModel>> login(LoginRequestModel request);

  /// Register new user account
  Future<Either<Exception, RegisterResponseModel>> register(
    RegisterRequestModel request,
  );

  /// Request password reset via username
  Future<Either<Exception, ForgotPasswordResponseModel>> forgotPassword(
    ForgotPasswordRequestModel request,
  );

  /// Authenticate as guest user
  Future<Either<Exception, GuestAuthResponseModel>> guestAuth(
    GuestAuthRequestModel request,
  );

  /// Register guest user as permanent user
  Future<Either<Exception, GuestRegisterResponseModel>> guestRegister(
    GuestRegisterRequestModel request,
  );

  /// Change user password
  Future<Either<Exception, ChangePasswordResponseModel>> changePassword(
    ChangePasswordRequestModel request,
  );

  /// Logout user
  Future<Either<Exception, void>> logout();
}
