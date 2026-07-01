import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:network/network.dart';
import 'package:template_c/core/constant/api_endpoints.dart';
import 'package:template_c/feat/interest/data/models/interest_config_response_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:template_c/feat/interest/data/models/toggle_onboarded_status_model.dart';
import 'package:template_c/feat/interest/data/models/selected_response_model.dart';
import 'package:template_c/feat/interest/data/models/update_selected_request_model.dart';

final interestServiceProvider = Provider<InterestService>((ref) {
  final apiHelper = ref.watch(apiHelperProvider);
  return InterestService(apiHelper: apiHelper);
});

class InterestService {
  final ApiHelper _apiHelper;

  InterestService({required ApiHelper apiHelper}) : _apiHelper = apiHelper;

  bool get _isLiveMode {
    final base = dotenv.maybeGet('BASE_URL') ?? '';
    return base.isNotEmpty && !base.startsWith('YOUR_');
  }

  Future<Either<Exception, InterestConfigResponseModel>> getInterestConfig() async {
    if (!_isLiveMode) {
      final jsonStr = await rootBundle.loadString('assets/config/interests.json');
      final data = json.decode(jsonStr) as Map<String, dynamic>;
      return Right(InterestConfigResponseModel().fromJson(data));
    }
    final result = await _apiHelper.getRequest<InterestConfigResponseModel>(
      path: ApiEndpoints.getInterestConfig,
      create: () => InterestConfigResponseModel(),
    );
    return result.fold((error) => Left(error), (response) => Right(response));
  }

  Future<Either<Exception, SelectedResponseModel>> getSelectedInterest() async {
    if (!_isLiveMode) {
      return Right(SelectedResponseModel());
    }
    final result = await _apiHelper.getRequest<SelectedResponseModel>(
      path: ApiEndpoints.getSelectedInterest,
      create: () => SelectedResponseModel(),
    );
    return result.fold((error) => Left(error), (response) => Right(response));
  }

  Future<Either<Exception, SelectedResponseModel>> updateSelectedInterest(
    UpdateSelectedRequestModel request,
  ) async {
    if (!_isLiveMode) {
      return Right(SelectedResponseModel());
    }
    final result = await _apiHelper.postRequest<SelectedResponseModel>(
      path: ApiEndpoints.getSelectedInterest,
      body: request.toJson(),
      create: () => SelectedResponseModel(),
    );
    return result.fold((error) => Left(error), (response) => Right(response));
  }

  Future<Either<Exception, ToggleOnboardedStatusResponseModel>> toggleOnboardedStatus(
    ToggleOnboardedStatusRequestModel request,
  ) async {
    if (!_isLiveMode) {
      return Right(ToggleOnboardedStatusResponseModel());
    }
    final result = await _apiHelper.putRequest<ToggleOnboardedStatusResponseModel>(
      path: ApiEndpoints.toggleOnboardedStatus,
      body: request.toJson(),
      create: () => ToggleOnboardedStatusResponseModel(),
    );
    return result.fold((error) => Left(error), (response) => Right(response));
  }
}
