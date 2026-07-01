import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:template_a/feat/auth/data/models/forgot_password_request_model.dart';
import 'package:template_a/feat/auth/data/models/forgot_password_response_model.dart';
import 'package:template_a/feat/auth/data/models/login_request_model.dart';
import 'package:template_a/feat/auth/data/models/login_response_model.dart';
import 'package:template_a/feat/auth/data/models/register_request_model.dart';
import 'package:template_a/feat/auth/data/models/register_response_model.dart';
import 'package:template_a/feat/auth/domain/repositories/auth_repository.dart';
import 'package:template_a/feat/auth/services/auth_service.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthService _authService;

  AuthRepositoryImpl(this._authService);

  @override
  Future<Either<Exception, LoginResponseModel>> login(
    LoginRequestModel request,
  ) async {
    final result = await _authService.login(request);

    if (result.isLeft()) return result;

    final loginResponse = result.fold((l) => null, (r) => r)!;
    await _authService.saveTokens(
      accessToken: loginResponse.accessToken ?? '',
      refreshToken: loginResponse.refreshToken ?? '',
      expiresIn: loginResponse.expiresIn ?? 3600,
    );
    await _authService.setLoggedIn();
    return Right(loginResponse);
  }

  @override
  Future<Either<Exception, LoginResponseModel>> guestLogin({
    required String deviceId,
  }) async {
    final result = await _authService.guestLogin(deviceId: deviceId);

    if (result.isLeft()) return result;

    final loginResponse = result.fold((l) => null, (r) => r)!;
    await _authService.saveTokens(
      accessToken: loginResponse.accessToken ?? '',
      refreshToken: loginResponse.refreshToken ?? '',
      expiresIn: loginResponse.expiresIn ?? 3600,
    );
    await _authService.setLoggedIn();
    await _authService.setGuestUser();
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
    return await _authService.forgotPassword(request);
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthRepositoryImpl(authService);
});
