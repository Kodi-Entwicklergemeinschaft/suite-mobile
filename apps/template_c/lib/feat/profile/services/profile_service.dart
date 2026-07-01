import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:network/network.dart';
import 'package:template_c/core/constant/api_endpoints.dart';
import 'package:template_c/feat/profile/data/models/faq_model.dart';
import 'package:template_c/feat/profile/data/models/profile_model.dart';

final profileServiceProvider = Provider<ProfileService>((ref) {
  final apiHelper = ref.watch(apiHelperProvider);
  return ProfileService(apiHelper: apiHelper);
});

class ProfileService {
  final ApiHelper _apiHelper;

  ProfileService({required ApiHelper apiHelper}) : _apiHelper = apiHelper;

  bool get _isLiveMode {
    final base = dotenv.maybeGet('BASE_URL') ?? '';
    return base.isNotEmpty && !base.startsWith('YOUR_');
  }

  Future<Either<Exception, ProfileModel>> getProfile() async {
    if (!_isLiveMode) {
      final jsonStr = await rootBundle.loadString('assets/config/profile.json');
      final data = json.decode(jsonStr) as Map<String, dynamic>;
      return Right(ProfileModel().fromJson(data));
    }
    return await _apiHelper.getRequest<ProfileModel>(
      path: ApiEndpoints.profileGet,
      create: () => ProfileModel(),
    );
  }

  Future<Either<Exception, ProfileModel>> updateProfile(
    Map<String, dynamic> data, {
    required String userId,
  }) async {
    if (!_isLiveMode) {
      return Right(ProfileModel());
    }
    final path = '${ApiEndpoints.profileBase}/$userId';
    return await _apiHelper.putRequest<ProfileModel>(
      path: path,
      body: data,
      create: () => ProfileModel(),
    );
  }

  Future<Either<Exception, ProfileModel>> deleteAccount({String? userId}) async {
    if (!_isLiveMode) {
      return Right(ProfileModel());
    }
    final path = '${ApiEndpoints.profileBase}/$userId';
    return await _apiHelper.deleteRequest<ProfileModel>(
      path: path,
      create: () => ProfileModel(),
    );
  }

  Future<Either<Exception, FAQModel>> getFAQ() async {
    if (!_isLiveMode) {
      final jsonStr = await rootBundle.loadString('assets/config/faq.json');
      final data = json.decode(jsonStr) as Map<String, dynamic>;
      return Right(FAQModel().fromJson(data));
    }
    return await _apiHelper.getRequest<FAQModel>(
      path: ApiEndpoints.faqConfig,
      create: () => FAQModel(),
    );
  }
}
