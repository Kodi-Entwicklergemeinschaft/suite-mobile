import 'dart:developer' as developer;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:template_c/core/constant/common_enums.dart';
import 'package:template_c/feat/auth/data/models/request_model/change_password_request_model.dart';
import 'package:template_c/feat/auth/domain/usecases/change_password_usecase.dart';
import 'package:template_c/feat/profile/state/change_password_state.dart';

/// Provider for change password controller
final changePasswordControllerProvider =
    NotifierProvider.autoDispose<ChangePasswordNotifier, ChangePasswordState>(
      () => ChangePasswordNotifier(),
    );

/// Notifier managing change password logic
class ChangePasswordNotifier extends Notifier<ChangePasswordState> {
  late ChangePasswordUseCase _changePasswordUseCase;

  @override
  ChangePasswordState build() {
    _changePasswordUseCase = ref.read(changePasswordUseCaseProvider);
    return const ChangePasswordState();
  }

  /// Submit password change request
  Future<void> submitPasswordChange({
    required String currentPassword,
    required String newPassword,
  }) async {
    state = state.copyWith(state: StateEnum.loadingDialog);

    try {
      // Create change password request model
      final changePasswordRequest = ChangePasswordRequestModel(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );

      // Call change password usecase
      final result = await _changePasswordUseCase.call(changePasswordRequest);

      // Handle result
      result.fold(
        (error) {
          // Log error response
          developer.log(
            'Change Password Error: $error',
            name: 'ChangePasswordController.submitPasswordChange',
            error: error,
          );
          state = state.copyWith(
            state: StateEnum.errorSnackBar,
            message: error.toString(),
          );
        },
        (changePasswordResponse) {
          // Log success response
          developer.log(
            'Change Password Success: ${changePasswordResponse.message}',
            name: 'ChangePasswordController.submitPasswordChange',
          );
          // Handle success
          state = state.copyWith(
            state: StateEnum.success,
            message: changePasswordResponse.message,
          );
        },
      );
    } catch (e) {
      state = state.copyWith(
        state: StateEnum.errorSnackBar,
        message: e.toString(),
      );
    }
  }

  /// Reset state to initial
  void reset() {
    state = const ChangePasswordState();
  }
}
