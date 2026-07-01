import 'package:network/network.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:template_b/core/constants/api_endpoints.dart';
import 'package:template_b/feat/feedback/model/request/feedback_request_model.dart';
import 'package:template_b/feat/feedback/model/response/feedback_response_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final feedbackServiceProvider = Provider(
  (ref) => FeedbackService(apiHelper: ref.read(apiHelperProvider)),
);

class FeedbackService {
  ApiHelper apiHelper;

  FeedbackService({required this.apiHelper});

  bool get _isLiveMode {
    final base = dotenv.maybeGet('BASE_URL') ?? '';
    return base.isNotEmpty && !base.startsWith('YOUR_');
  }

  Future<Either<Exception, FeedbackResponseModel>> submit(
    FeedbackRequestModel params,
  ) async {
    if (!_isLiveMode) return Right(FeedbackResponseModel());
    final result = await apiHelper.postRequest(
      path: ApiEndpoints.feedbackConfig,
      create: () => FeedbackResponseModel(),
      body: params.toJson(),
    );
    return result.fold(
      (failure) => Left(failure),
      (response) => Right(response),
    );
  }
}
