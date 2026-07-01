import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:network/network.dart';
import 'package:template_c/feat/auth/serivces/auth_service.dart';
import 'package:template_c/feat/profile/data/models/edit_profile_request_model.dart';
import 'package:template_c/feat/profile/data/models/faq_model.dart';
import 'package:template_c/feat/profile/data/models/profile_model.dart';
import 'package:template_c/feat/profile/domain/repositories/profile_repository.dart';
import 'package:template_c/feat/profile/services/profile_service.dart';

/// Implementation of ProfileRepository
/// Responsibility: Business logic, validation, data transformation
/// Calls ProfileService for API calls
class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileService _profileService;
  final AuthService _authService;

  ProfileRepositoryImpl(this._profileService, this._authService);

  @override
  Future<Either<Exception, ProfileModel>> getProfile() async {
    final result = await _profileService.getProfile();
    return result.fold(
      (error) => Left(error),
      (profileModel) => Right(profileModel),
    );
  }

  @override
  Future<Either<Exception, ProfileModel>> updateProfile(
    EditProfileRequestModel request, {required String userId}
  ) async {
    final result = await _profileService.updateProfile(
      request.toJson(),
      userId: userId,
    );
    return result.fold(
      (error) => Left(error),
      (profileModel) => Right(profileModel),
    );
  }

  @override
  Future<Either<Exception, void>> deleteAccount({String? userId}) async {
    final result = await _profileService.deleteAccount(userId: userId);
    return result.fold(
      (error) => Left(error),
      (_) async {
        await _authService.clearTokens();
        return const Right(null);
      },
    );
  }

  @override
  Future<Either<Exception, FAQModel>> getFAQ() async {
    final result = await _profileService.getFAQ();
    return result.fold(
      (error) => Left(error),
      (faq) => Right(faq),
    );
  }
}

/// Riverpod provider for ProfileRepository
final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final profileService = ref.watch(profileServiceProvider);
  final authService = ref.watch(authServiceProvider);
  return ProfileRepositoryImpl(profileService, authService);
});
