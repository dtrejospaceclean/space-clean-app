/// An image picked on the device, to become the user's profile photo
/// (`PUT /auth/me/photo`). The server checks the real type (JPEG, PNG or
/// WebP), crops it to a square and drops its EXIF data.
class ProfilePhoto {
  const ProfilePhoto({required this.path, required this.sizeInBytes});

  /// A local file path.
  final String path;
  final int sizeInBytes;

  /// The server refuses anything larger (`users.photo_too_large`).
  static const maxBytes = 5 * 1024 * 1024;

  bool get isTooLarge => sizeInBytes > maxBytes;
}
