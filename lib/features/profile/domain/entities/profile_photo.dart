import 'dart:typed_data';

/// An image picked on the device, to become the user's profile photo
/// (`PUT /auth/me/photo`). The server checks the real type (JPEG, PNG or
/// WebP), crops it to a square and drops its EXIF data.
///
/// Carries the bytes rather than a file path, since a browser has no file
/// system to read a path from.
class ProfilePhoto {
  const ProfilePhoto({required this.bytes, required this.name});

  final Uint8List bytes;

  /// The picked file's name, sent as the upload's filename.
  final String name;

  int get sizeInBytes => bytes.length;

  /// The server refuses anything larger (`users.photo_too_large`).
  static const maxBytes = 5 * 1024 * 1024;

  bool get isTooLarge => sizeInBytes > maxBytes;
}
