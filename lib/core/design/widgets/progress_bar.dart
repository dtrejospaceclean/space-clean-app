import 'package:flutter/material.dart';

import '../tokens.dart';

/// Rounded progress: navy fill on a light navy track, or a status's own
/// [color] on a neutral track (a job's progress in its status color).
class SpaceProgressBar extends StatelessWidget {
  const SpaceProgressBar({
    super.key,
    required this.value,
    this.height = 10,
    this.semanticsLabel,
    this.color,
  });

  /// 0–1.
  final double value;
  final double height;
  final String? semanticsLabel;

  /// The fill; defaults to navy. With a color the track turns sunken.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final v = value.clamp(0.0, 1.0);
    return Semantics(
      label: semanticsLabel,
      value: '${(v * 100).round()}%',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(SpaceRadius.pill),
        child: SizedBox(
          height: height,
          child: Stack(
            fit: StackFit.expand,
            children: [
              ColoredBox(
                color: color == null
                    ? context.colors.accentSoft
                    : context.colors.sunken,
              ),
              FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: v,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: color ?? context.colors.accent,
                    borderRadius: BorderRadius.circular(SpaceRadius.pill),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
