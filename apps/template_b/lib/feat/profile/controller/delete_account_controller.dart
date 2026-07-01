import 'dart:developer' as developer;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:network/network.dart';
import 'package:preference_manager/shared_pref.dart';
import 'package:template_b/core/providers/auth_state_provider.dart';
import 'package:template_b/feat/auth/service/auth_service.dart';
import 'package:template_b/feat/profile/domain/usecases/delete_account_usecase.dart';
import 'package:template_b/feat/profile/state/delete_account.dart';

final deleteAccountControllerProvider =
    NotifierProvider.autoDispose<DeleteAccountNotifier, DeleteAccountState>(
  () => DeleteAccountNotifier(),
);

class DeleteAccountNotifier extends Notifier<DeleteAccountState> {
  late DeleteAccountUseCase _deleteAccountUseCase;

  @override
  DeleteAccountState build() {
    _deleteAccountUseCase = ref.read(deleteAccountUseCaseProvider);
    return DeleteAccountState();
  }

  Future<void> deleteAccount({String? userId}) async {
    if (userId == null || userId.isEmpty) {
      state = state.copyWith(
        isLoading: false,
        error: 'User ID is required to delete account',
      );
      return;
    }

    state = state.copyWith(isLoading: true, error: null);
    final result =
        await _deleteAccountUseCase.call(const NoParams(), userId: userId);
    await result.fold(
      (error) async {
        developer.log(
          'Delete Account Error: $error',
          name: 'DeleteAccountController.deleteAccount',
          error: error,
        );
        state = state.copyWith(isLoading: false, error: error.toString());
      },
      (_) async {
        developer.log(
          'Delete Account Success - clearing local data',
          name: 'DeleteAccountController.deleteAccount',
        );
        ref.read(authStateProvider.notifier).setLoggedOut();
        state = state.copyWith(isLoading: false, isSuccess: true);
      },
    );
  }
}