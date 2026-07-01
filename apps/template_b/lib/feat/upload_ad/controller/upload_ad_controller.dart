import 'dart:io';

import 'package:common_components/common_components.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:template_b/feat/upload_ad/state/upload_ad_state.dart';

final uploadAdControllerProvider =
    NotifierProvider.autoDispose<UploadAdController, UploadAddState>(
      () => UploadAdController(),
    );

class UploadAdController extends Notifier<UploadAddState> {
  @override
  UploadAddState build() {
    return UploadAddState(null, null);
  }

  updatePackageName(String name) {
    state = state.copyWith(packageName: name);
  }

  updateImageFile(File? file) async {
    state = state.copyWith(imageFile: file);
  }
}
