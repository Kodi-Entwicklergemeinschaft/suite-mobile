import 'package:dartz/dartz.dart';
import 'package:template_b/feat/feedback/model/request/feedback_request_model.dart';
import 'package:template_b/feat/feedback/model/response/feedback_response_model.dart';

abstract class FeedbackRepo {
  Future<Either<Exception, FeedbackResponseModel>> submit(
    FeedbackRequestModel params,
  );
}
