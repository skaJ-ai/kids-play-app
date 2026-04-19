import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';

abstract class AvatarPhotoPicker {
  Future<Uint8List?> pickFromGallery();
}

class ImagePickerAvatarPhotoPicker implements AvatarPhotoPicker {
  ImagePickerAvatarPhotoPicker(this._imagePicker);

  final ImagePicker _imagePicker;

  @override
  Future<Uint8List?> pickFromGallery() async {
    final file = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 2048,
      maxHeight: 2048,
      imageQuality: 90,
    );
    if (file == null) {
      return null;
    }

    return file.readAsBytes();
  }
}

class NoopAvatarPhotoPicker implements AvatarPhotoPicker {
  const NoopAvatarPhotoPicker();

  @override
  Future<Uint8List?> pickFromGallery() async => null;
}
