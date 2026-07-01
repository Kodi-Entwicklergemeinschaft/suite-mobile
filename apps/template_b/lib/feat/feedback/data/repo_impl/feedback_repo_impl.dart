import 'package:dartz/dartz.dart';
import 'package:template_b/feat/feedback/data/service/feedback_service.dart';
import 'package:template_b/feat/feedback/domain/repo/feedback_repo.dart';
import 'package:template_b/feat/feedback/model/request/feedback_request_model.dart';
import 'package:template_b/feat/feedback/model/response/feedback_response_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final feedbackRepoImplProvider = Provider(
  (ref) => FeedbackRepoImpl(feedbackService: ref.read(feedbackServiceProvider)),
);

class FeedbackRepoImpl implements FeedbackRepo {
  FeedbackService feedbackService;

  FeedbackRepoImpl({required this.feedbackService});

  @override
  Future<Either<Exception, FeedbackResponseModel>> submit(
    FeedbackRequestModel params,
  ) async {
    final res = await feedbackService.submit(params);
    return res.fold((l) => Left(l), (r) => Right(r));
  }
}
