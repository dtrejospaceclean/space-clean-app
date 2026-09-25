import 'package:flutter/material.dart';

import '../tokens.dart';

enum NoticeTone { error, info, success }

/// A soft tinted card for form-level errors and notices.
class Notice extends StatelessWidget {
  const Notice({
    super.key,
    required this.message,
    this.tone = NoticeTone.error,
  });

  final String message;
  final NoticeTone tone;

  @override
  Widget build(BuildContext context) {
    final (IconData icon, Color color, Color background) = switch (tone) {
      NoticeTone.error => (
        Icons.error_rounded,
        context.colors.danger,
        context.colors.dangerSoft,
      ),
      NoticeTone.info => (
        Icons.info_rounded,
        context.colors.accent,
        context.colors.accentSoft,
      ),
      NoticeTone.success => (
        Icons.check_circle_rounded,
        context.colors.success,
        context.colors.successSoft,
      ),
    };

    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(SpaceRadius.inner),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  fontFamily: 'Manrope',
                  color: context.colors.ink,
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
