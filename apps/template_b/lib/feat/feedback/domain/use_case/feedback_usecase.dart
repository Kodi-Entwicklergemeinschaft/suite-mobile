import 'package:flutter/material.dart';
import 'package:network/network.dart';
import 'package:template_b/feat/feedback/data/repo_impl/feedback_repo_impl.dart';
import 'package:template_b/feat/feedback/domain/repo/feedback_repo.dart';
import 'package:template_b/feat/feedback/model/request/feedback_request_model.dart';
import 'package:template_b/feat/feedback/model/response/feedback_response_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final feedbackUseCaseProvider = Provider(
  (ref) => FeedbackUsecase(feedbackRepo: ref.read(feedbackRepoImplProvider)),
);

class FeedbackUsecase
    implements BaseUseCase<FeedbackResponseModel, FeedbackRequestModel> {
  FeedbackRepo feedbackRepo;

  FeedbackUsecase({required this.feedbackRepo});

  @override
  Future<Either<Exception, FeedbackResponseModel>> call(
    FeedbackRequestModel params,
  ) async {
    final res = await feedbackRepo.submit(params);

    return res.fold((l) => Left(l), (r) => Right(r));
  }
}
