import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:template_b/feat/feedback/model/request/feedback_request_model.dart';
import 'package:template_b/feat/feedback/state/feedback_state.dart';
import '../domain/use_case/feedback_usecase.dart';

final feedbackControllerProvider =
    NotifierProvider<FeedbackController, FeedbackState>(
      () => FeedbackController(),
    );

class FeedbackController extends Notifier<FeedbackState> {
  FeedbackUsecase get _feedbackUseCase => ref.read(feedbackUseCaseProvider);

  @override
  FeedbackState build() {
    return FeedbackState(false);
  }

  submitForm({
    required String email,
    required String informatiom,
    required Function(String) onError,
    required Function(String) onSuccess,
  }) async {
    try {
      state = state.copyWith(isLoading: true);
      FeedbackRequestModel params = FeedbackRequestModel(
        email: email,
        information: informatiom,
      );

      final res = await _feedbackUseCase.call(params);
      res.fold(
        (l) {
          onError(l.toString());
        },
        (r) {
          onSuccess(r.message ?? '');
        },
      );
    } catch (e) {
      debugPrint('Error submitting feedback: $e');

      onError(e.toString());
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }
}
