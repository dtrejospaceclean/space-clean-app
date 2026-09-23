import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../theme/threshold_palette.dart';

/// The logo (full color on white, white knockout on ember) with the tagline.
///
/// Gives way to the form so its action stays in the first viewport:
/// - [compact] (keyboard open), or large text on a short screen: small logo,
///   no tagline;
/// - [condensed] (a notice is taking room): smaller logo, tagline kept.
class BrandBlock extends StatelessWidget {
  const BrandBlock({
    super.key,
    this.tagline,
    this.compact = false,
    this.condensed = false,
  });

  final String? tagline;
  final bool compact;
  final bool condensed;

  static const _duration = Duration(milliseconds: 280);
  static const _curve = Curves.easeOutCubic;

  @override
  Widget build(BuildContext context) {
    final palette = ThresholdPalette.of(context);
    final screenHeight = MediaQuery.sizeOf(context).height;
    final largeTextOnShortScreen =
        MediaQuery.textScalerOf(context).scale(10) >= 13 && screenHeight < 700;
    final small = compact || largeTextOnShortScreen;
    final logoHeight = small
        ? 64.0
        : condensed
        ? (screenHeight * 0.12).clamp(80.0, 104.0)
        : (screenHeight * 0.17).clamp(104.0, 160.0);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: _duration,
          curve: _curve,
          height: logoHeight,
          child: SvgPicture.asset(
            palette.logoAsset,
            semanticsLabel: 'Space Clean',
            fit: BoxFit.contain,
          ),
        ),
        // Not wrapped in AnimatedSize: it reports its target height while
        // painting the animated one, and the threshold layout sizes itself
        // from the reported height, so every reflow (keyboard, language
        // switch) overflowed for the length of the animation. The logo above
        // carries the motion.
        if (!small && tagline != null)
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Text(
              tagline!,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: palette.onGroundMuted,
                fontWeight: FontWeight.w500,
                height: 1.35,
              ),
            ),
          ),
      ],
    );
  }
}
