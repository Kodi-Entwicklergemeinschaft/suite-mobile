import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:template_b/feat/contact/model/request/contact_request_model.dart';
import 'package:template_b/feat/contact/state/contact_state.dart';
import '../domain/use_case/contact_usecase.dart';

final contactControllerProvider =
    NotifierProvider<ContactController, ContactState>(
      () => ContactController(),
    );

class ContactController extends Notifier<ContactState> {
  ContactUsecase get _contactUseCase => ref.read(contactUseCaseProvider);

  @override
  ContactState build() {
    return ContactState(false);
  }

  submitForm({
    required String email,
    required String firstName,
    required String phoneNumber,
    required String lastName,
    required String message,

    required Function(String) onSuccess,
    required Function(String) onError,
  }) async {
    try {
      state = state.copyWith(isLoading: true);
      final res = await _contactUseCase(
        ContactRequestModel(
          email: email,
          firstName: firstName,
          phoneNumber: phoneNumber,
          lastName: lastName,
          message: message,
        ),
      );

      res.fold(
        (l) {
          onError(l.toString());
        },
        (r) {
          onSuccess(r.message ?? 'success');
        },
      );
    } catch (e) {
      onError(e.toString());
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }
}
