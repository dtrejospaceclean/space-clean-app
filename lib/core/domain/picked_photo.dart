/// An image picked on the device, to be uploaded: a profile photo
/// (`PUT /auth/me/photo`) or a complaint's (`POST …/complaints/:id/photos`).
/// The server checks the real type (JPEG, PNG or WebP), re-encodes it and
/// drops its EXIF data.
class PickedPhoto {
  const PickedPhoto({required this.path, required this.sizeInBytes});

  /// A local file path.
  final String path;
  final int sizeInBytes;

  /// The server refuses anything larger (`*.photo_too_large`).
  static const maxBytes = 5 * 1024 * 1024;

  bool get isTooLarge => sizeInBytes > maxBytes;
}
