import 'dart:io';

class UploadAddState {
  String? packageName;
  File? imageFile;

  UploadAddState(this.packageName,this.imageFile);

  UploadAddState copyWith({String? packageName,File? imageFile}) {
    return UploadAddState(packageName ?? this.packageName,
    imageFile??this.imageFile);
  }
}
