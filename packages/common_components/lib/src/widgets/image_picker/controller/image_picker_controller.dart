import 'dart:io';
import 'package:common_components/src/widgets/image_picker/state/image_picker_state.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:common_components/src/widgets/image_picker/controller/image_compression.dart';
import 'package:common_components/common_components.dart';
import 'package:locale/locale.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final imagePickerControllerProvider =
    NotifierProvider<ImagePickerController, ImagePickerState>(
        () => ImagePickerController());

class ImagePickerController extends Notifier<ImagePickerState> {
  final ImagePicker _imagePicker = ImagePicker();

  @override
  ImagePickerState build() {
    return ImagePickerState();
  }

  /// custom dialog to pick image
  Future<File?> pickImageWithDialog(BuildContext context) async {
    File? selectedImage;

    await CommonSheet.showWithChild<void>(
      context,
      title: 'select_image_source'.tr,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: Icon(
              Icons.photo_library,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: Text('gallery'.tr),
            onTap: () async {
              final image = await _pickImageFromGallery();
              if (image != null) {
                final originalSize = await image.length();
                debugPrint(
                    '[ImagePicker] Gallery - Original file size: ${(originalSize / 1024 / 1024).toStringAsFixed(2)} MB');

                final compressedFile = await compressFile(XFile(image.path));
                final compressedSize = await File(compressedFile.path).length();
                debugPrint(
                    '[ImagePicker] Gallery - Compressed file size: ${(compressedSize / 1024 / 1024).toStringAsFixed(2)} MB');
                debugPrint(
                    '[ImagePicker] Gallery - Compression ratio: ${(100 - (compressedSize / originalSize * 100)).toStringAsFixed(1)}%');

                selectedImage = File(compressedFile.path);
              }
              if (context.mounted) {
                context.pop();
              }
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: Icon(
              Icons.camera_alt,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: Text('camera'.tr),
            onTap: () async {
              final image = await _pickImageFromCamera();
              if (image != null) {
                final originalSize = await image.length();
                debugPrint(
                    '[ImagePicker] Camera - Original file size: ${(originalSize / 1024 / 1024).toStringAsFixed(2)} MB');

                final compressedFile = await compressFile(XFile(image.path));
                final compressedSize = await File(compressedFile.path).length();
                debugPrint(
                    '[ImagePicker] Camera - Compressed file size: ${(compressedSize / 1024 / 1024).toStringAsFixed(2)} MB');
                debugPrint(
                    '[ImagePicker] Camera - Compression ratio: ${(100 - (compressedSize / originalSize * 100)).toStringAsFixed(1)}%');

                selectedImage = File(compressedFile.path);
              }
              if (context.mounted) {
                context.pop();
              }
            },
          ),
        ],
      ),
    );

    return selectedImage;
  }

  /// Common method to pick image
  Future<XFile?> _pickImage({
    required ImageSource source,
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
  }) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        imageQuality: imageQuality ?? 100,
      );

      return image;
    } catch (e) {
      debugPrint('Error picking image: $e');
      return null;
    }
  }

  /// Pick image from gallery only
  Future<File?> _pickImageFromGallery({
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
  }) async {
    try {
      final file = await _pickImage(
        source: ImageSource.gallery,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        imageQuality: imageQuality,
      );

      if (file != null) {
        return File(file.path);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  /// Pick image from camera only
  Future<File?> _pickImageFromCamera({
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
  }) async {
    try {
      final file = await _pickImage(
        source: ImageSource.camera,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        imageQuality: imageQuality,
      );

      if (file != null) {
        return File(file.path);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  /// Get file from XFile
  File? getFileFromXFile(XFile? xFile) {
    if (xFile == null) return null;
    return File(xFile.path);
  }

  /// Get file path from XFile
  String? getFilePathFromXFile(XFile? xFile) {
    return xFile?.path;
  }
}
