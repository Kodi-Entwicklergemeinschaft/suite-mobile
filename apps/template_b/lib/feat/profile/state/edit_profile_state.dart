import 'dart:io';

class EditProfileState {
  final bool isLoading;
  final bool isUploadingImage;


  final bool pendingDelete;

  final String? error;
  final bool isSuccess;
  final String? successMessage;
  final File? file;

  EditProfileState({
    this.isLoading = false,
    this.isUploadingImage = false,
    this.pendingDelete = false,
    this.error,
    this.isSuccess = false,
    this.successMessage,
    this.file,
  });

  EditProfileState copyWith({
    bool? isLoading,
    bool? isUploadingImage,
    bool? pendingDelete,
    String? error,
    bool? isSuccess,
    String? successMessage,
    File? file,
    bool clearFile = false,
  }) =>
      EditProfileState(
        isLoading: isLoading ?? this.isLoading,
        isUploadingImage: isUploadingImage ?? this.isUploadingImage,
        pendingDelete: pendingDelete ?? this.pendingDelete,
        error: error,
        isSuccess: isSuccess ?? this.isSuccess,
        successMessage: successMessage ?? this.successMessage,
        file: clearFile ? null : (file ?? this.file),
      );
}
