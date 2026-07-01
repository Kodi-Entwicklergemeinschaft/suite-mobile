import 'dart:convert';
import 'dart:developer' as dev;
import 'package:dartz/dartz.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:network/network.dart';
import 'package:template_b/core/constants/api_endpoints.dart';
import 'package:template_b/feat/profile/data/models/profile_model.dart';
import 'package:template_b/feat/profile/data/models/faq_model.dart';

/// Provider for ProfileService
final profileServiceProvider = Provider<ProfileService>((ref) {
  final apiHelper = ref.watch(apiHelperProvider);
  return ProfileService(apiHelper: apiHelper);
});

/// Service for handling profile-related API calls
class ProfileService {
  final ApiHelper _apiHelper;

  ProfileService({required ApiHelper apiHelper}) : _apiHelper = apiHelper;

  bool get _isLiveMode {
    final base = dotenv.maybeGet('BASE_URL') ?? '';
    return base.isNotEmpty && !base.startsWith('YOUR_');
  }

  /// Fetch user profile from API
  Future<Either<Exception, ProfileModel>> getProfile() async {
    if (!_isLiveMode) return Right(ProfileModel());
    return await _apiHelper.getRequest<ProfileModel>(
      path: ApiEndpoints.profileGet,
      create: () => ProfileModel(),
    );
  }

  /// Update user profile.
  Future<Either<Exception, ProfileModel>> updateProfile(
    Map<String, dynamic> data, {
    required String userId,
  }) async {
    if (!_isLiveMode) return Right(ProfileModel());
    final path = '${ApiEndpoints.profileBase}/$userId';
    return await _apiHelper.putRequest<ProfileModel>(
      path: path,
      body: data,
      create: () => ProfileModel(),
    );
  }

  /// Delete user account
  Future<Either<Exception, ProfileModel>> deleteAccount({
    String? userId,
  }) async {
    if (!_isLiveMode) return Right(ProfileModel());
    final path = '${ApiEndpoints.profileBase}/$userId';
    return await _apiHelper.deleteRequest<ProfileModel>(
      path: path,
      create: () => ProfileModel(),
    );
  }

  Future<Either<Exception, FAQModel>> getFAQ() async {
    try {
      dev.log('[ProfileService] Loading FAQ from local asset');
      final jsonStr = await rootBundle.loadString('assets/config/faq.json');
      final data = json.decode(jsonStr) as Map<String, dynamic>;
      dev.log('[ProfileService] Loaded FAQ from asset');
      return Right(FAQModel().fromJson(data));
    } catch (e) {
      return Left(Exception('Failed to load FAQ: $e'));
    }
  }
}
