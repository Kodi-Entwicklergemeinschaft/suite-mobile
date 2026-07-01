import 'dart:io';

import 'package:template_c/core/constant/common_enums.dart';

class EditProfileState {
  final StateEnum state;
  final String? message;
  final bool isUploadingImage;
  final bool pendingDelete;
  final File? file;

  EditProfileState({
    this.isUploadingImage = false,
    this.pendingDelete = false,
    this.file,
    this.state = StateEnum.initial,
    this.message,
  });

  EditProfileState copyWith({
    StateEnum? state,
    String? message,
    bool? isUploadingImage,
    bool? pendingDelete,
    File? file,
    bool clearFile = false,
  }) {
    return EditProfileState(
      state: state ?? this.state,
      message: message ?? this.message,
      isUploadingImage: isUploadingImage ?? this.isUploadingImage,
      pendingDelete: pendingDelete ?? this.pendingDelete,
      file: clearFile ? null : (file ?? this.file),
    );
  }
}
