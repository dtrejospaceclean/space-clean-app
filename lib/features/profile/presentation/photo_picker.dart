import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../domain/entities/profile_photo.dart';

enum PhotoSource { camera, library }

/// Takes or chooses a photo on the device. Returns `null` when the user
/// backs out. Throws [PhotoAccessDenied] when the app may not use the
/// camera or the library.
abstract interface class PhotoPicker {
  Future<ProfilePhoto?> pick(PhotoSource source);
}

class PhotoAccessDenied implements Exception {
  const PhotoAccessDenied();
}

/// The system camera and photo picker (`image_picker`).
class DevicePhotoPicker implements PhotoPicker {
  const DevicePhotoPicker();

  // The server keeps a 512 px square, so a smaller copy loses nothing and
  // stays well under its 5 MB limit. Re-encoding also turns an iPhone's
  // HEIC into JPEG, which the server accepts.
  static const _maxSide = 1600.0;
  static const _quality = 90;

  @override
  Future<ProfilePhoto?> pick(PhotoSource source) async {
    final XFile? file;
    try {
      file = await ImagePicker().pickImage(
        source: switch (source) {
          PhotoSource.camera => ImageSource.camera,
          PhotoSource.library => ImageSource.gallery,
        },
        preferredCameraDevice: CameraDevice.front,
        maxWidth: _maxSide,
        maxHeight: _maxSide,
        imageQuality: _quality,
        requestFullMetadata: false,
      );
    } on PlatformException catch (e) {
      // `camera_access_denied`, `photo_access_denied`…
      if (e.code.endsWith('access_denied')) throw const PhotoAccessDenied();
      rethrow;
    }
    if (file == null) return null;
    return ProfilePhoto(path: file.path, sizeInBytes: await file.length());
  }
}

final photoPickerProvider = Provider<PhotoPicker>(
  (ref) => const DevicePhotoPicker(),
);
