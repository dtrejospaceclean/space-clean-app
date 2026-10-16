import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdfrx/pdfrx.dart';

/// Shows PDF bytes (invoices, proposals). Tests replace it, since the real
/// viewer renders with a native library.
final pdfViewProvider = Provider<Widget Function(Uint8List bytes, String name)>(
  (ref) =>
      (bytes, name) => PdfViewer.data(bytes, sourceName: name),
);
