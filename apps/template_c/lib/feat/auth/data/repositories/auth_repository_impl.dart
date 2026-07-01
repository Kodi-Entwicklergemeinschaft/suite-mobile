import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:network/network.dart';
import 'package:template_c/core/constant/common_enums.dart';
import 'package:template_c/feat/auth/data/models/respnse_model/forgot_password_response_model.dart';
import 'package:template_c/feat/auth/data/models/respnse_model/guest_auth_response_model.dart';
import 'package:template_c/feat/auth/data/models/respnse_model/guest_register_response_model.dart';
import 'package:template_c/feat/auth/data/models/respnse_model/login_response_model.dart';
import 'package:template_c/feat/auth/data/models/respnse_model/me_response_model.dart';
import 'package:template_c/feat/auth/data/models/respnse_model/change_password_response_model.dart';
import 'package:template_c/feat/auth/serivces/auth_service.dart';
import '../models/request_model/login_request_model.dart';
import '../models/register_request_model.dart';
import '../models/respnse_model/register_response_model.dart';
import '../models/request_model/forgot_password_request_model.dart';
import '../models/request_model/guest_auth_request_model.dart';
import '../models/request_model/guest_register_request_model.dart';
import '../models/request_model/change_password_request_model.dart';
import '../../domain/repositories/auth_repository.dart';

/// Implementation of AuthRepository - orchestrates AuthService
class AuthRepositoryImpl implements AuthRepository {
  final AuthService _authService;

  AuthRepositoryImpl(this._authService);

  @override
  Future<Either<Exception, LoginResponseModel>> login(
    LoginRequestModel request,
  ) async {
    final result = await _authService.login(request.toJson());

    if (result.isLeft()) return result;

    final loginResponse = result.fold((l) => null, (r) => r)!;
    await _authService.saveTokens(
      accessToken: loginResponse.accessToken ?? '',
      refreshToken: loginResponse.refreshToken ?? '',
      expiresIn: loginResponse.expiresIn ?? 3600,
      role: UserRole.user,
      user: loginResponse.user,
    );
    return Right(loginResponse);
  }

  @override
  Future<Either<Exception, RegisterResponseModel>> register(
    RegisterRequestModel request,
  ) async {
    return await _authService.register(request);
  }

  @override
  Future<Either<Exception, ForgotPasswordResponseModel>> forgotPassword(
    ForgotPasswordRequestModel request,
  ) async {
    return await _authService.forgotPassword(request.toJson());
  }

  @override
  Future<Either<Exception, GuestAuthResponseModel>> guestAuth(
    GuestAuthRequestModel request,
  ) async {
    final result = await _authService.guestAuth(request.toJson());

    if (result.isLeft()) return result;

    final guestResponse = result.fold((l) => null, (r) => r)!;
    await _authService.saveTokens(
      accessToken: guestResponse.accessToken ?? '',
      refreshToken: guestResponse.refreshToken ?? '',
      expiresIn: guestResponse.expiresIn ?? 3600,
      role: UserRole.guest,
      user: UserModel(
        localityName: guestResponse.localityName,
        latitude: guestResponse.latitude,
        longitude: guestResponse.longitude,
        radius: guestResponse.radius,
      ),
    );
    return Right(guestResponse);
  }

  @override
  Future<Either<Exception, GuestRegisterResponseModel>> guestRegister(
    GuestRegisterRequestModel request,
  ) async {
    return await _authService.guestRegister(request.toJson());
  }

  @override
  Future<Either<Exception, ChangePasswordResponseModel>> changePassword(
    ChangePasswordRequestModel request,
  ) async {
    return await _authService.changePassword(request);
  }

  @override
  Future<Either<Exception, void>> logout() async {
    final result = await _authService.logout();

    return await result.fold((error) => Left(error), (_) async {
      await _authService.clearTokens();
      return Right(null);
    });
  }

  @override
  Future<Either<Exception, MeResponseModel>> getMe() {
    return _authService.getMe();
  }
}

/// Provider for AuthRepository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthRepositoryImpl(authService);
});
