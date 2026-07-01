import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:template_c/feat/legal/constant/legal_type.dart';
import 'package:template_c/feat/legal/domain/use_case/legal_usecase.dart';
import 'package:template_c/feat/legal/model/request/legal_request_model.dart';
import 'package:template_c/feat/legal/state/legal_state.dart';

final legalControllerProvider = NotifierProvider<LegalController, LegalState>(
  () => LegalController(),
);

class LegalController extends Notifier<LegalState> {
  LegalUsecase get _legalUsecase => ref.read(legalUsecaseProvider);
  @override
  LegalState build() {
    Future.microtask(
      () => getLegal(legalType: LegalType.imprint, onError: (_) {}),
    );
    return LegalState(null, false);
  }

  void getLegal({required LegalType legalType, required Function(String) onError}) async {
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
