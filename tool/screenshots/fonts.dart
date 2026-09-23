import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';

/// Loads real fonts so screenshot tests render glyphs instead of the test
/// font's boxes: every font in the app's FontManifest (Material and Cupertino
/// icons) plus Roboto from the Flutter SDK cache, which also stands in for
/// San Francisco on the iOS renders.
Future<void> loadScreenshotFonts() async {
  final manifest =
      jsonDecode(await rootBundle.loadString('FontManifest.json')) as List;
  for (final family in manifest.cast<Map<String, dynamic>>()) {
    final loader = FontLoader(family['family'] as String);
    for (final font in (family['fonts'] as List).cast<Map<String, dynamic>>()) {
      loader.addFont(rootBundle.load(font['asset'] as String));
    }
    await loader.load();
  }

  final fontsDir = _materialFontsDir();
  const roboto = [
    'roboto-regular.ttf',
    'roboto-medium.ttf',
    'roboto-bold.ttf',
    'roboto-black.ttf',
  ];
  for (final family in [
    'Roboto',
    'CupertinoSystemText',
    'CupertinoSystemDisplay',
    '.SF Pro Text',
    '.SF Pro Display',
    '.SF UI Text',
    '.SF UI Display',
  ]) {
    final loader = FontLoader(family);
    for (final file in roboto) {
      loader.addFont(
        File('${fontsDir.path}/$file').readAsBytes().then(ByteData.sublistView),
      );
    }
    await loader.load();
  }
}

Directory _materialFontsDir() {
  final fromEnv = Platform.environment['FLUTTER_ROOT'];
  if (fromEnv != null) {
    return Directory('$fromEnv/bin/cache/artifacts/material_fonts');
  }
  // flutter_tester lives under <flutter>/bin/cache/artifacts/engine/<platform>/.
  var dir = File(Platform.resolvedExecutable).parent;
  while (!Directory('${dir.path}/material_fonts').existsSync()) {
    dir = dir.parent;
  }
  return Directory('${dir.path}/material_fonts');
}
