import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../theme/brand_colors.dart';
import '../../theme/threshold_palette.dart';
import '../adaptive.dart';

enum NoticeTone { error, info }

/// A tinted panel for form-level errors and notices.
/// Errors are marked by a red icon on a light red tint.
class ThresholdNotice extends StatelessWidget {
  const ThresholdNotice({
    super.key,
    required this.message,
    this.tone = NoticeTone.error,
  });

  final String message;
  final NoticeTone tone;

  @override
  Widget build(BuildContext context) {
    final palette = ThresholdPalette.of(context);
    final cupertino = useCupertino(context);
    final (icon, color) = switch (tone) {
      NoticeTone.error => (
        cupertino ? CupertinoIcons.exclamationmark_circle_fill : Icons.error,
        BrandColors.danger,
      ),
      NoticeTone.info => (
        cupertino ? CupertinoIcons.info_circle_fill : Icons.info,
        BrandColors.navy,
      ),
    };

    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: tone == NoticeTone.error
              ? palette.noticeError
              : palette.noticeInfo,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: palette.onNotice,
                  fontWeight: FontWeight.w500,
                  height: 1.35,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
