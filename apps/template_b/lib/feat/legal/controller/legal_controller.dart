import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:template_b/feat/legal/constant/legal_type.dart';
import 'package:template_b/feat/legal/domain/use_case/legal_usecase.dart';
import 'package:template_b/feat/legal/model/request/legal_request_model.dart';
import 'package:template_b/feat/legal/model/response/legal_response_model.dart';
import 'package:template_b/feat/legal/state/legal_state.dart';

final legalControllerProvider = NotifierProvider<LegalController, LegalState>(
  () => LegalController(),
);

class LegalController extends Notifier<LegalState> {
  LegalUsecase get _legalUsecase => ref.read(legalUsecaseProvider);
  @override
  LegalState build() {
    return LegalState(null, false);
  }

  getLegal({required legalType, required Function(String) onError}) async {
    try {
      state = state.copyWith(isLoading: true, legalResponseModel: null);
      final result = await _legalUsecase(
        LegalRequestModel(legalType: legalType),
      );
      result.fold(
        (l) {
          debugPrint("Error fetching legal config: $l");
          onError(l.toString());
        },
        (r) {
          state = state.copyWith(legalResponseModel: r);
        },
      );
    } catch (e) {
      debugPrint("Error fetching legal config: $e");
      onError(e.toString());
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }
}
