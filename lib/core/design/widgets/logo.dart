import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// The Space Clean logo: full color on light grounds, the white knockout on
/// dark ones (the navy lettering disappears on a dark ground).
class SpaceLogo extends StatelessWidget {
  const SpaceLogo({super.key, required this.height});

  final double height;

  @override
  Widget build(BuildContext context) => SvgPicture.asset(
    Theme.of(context).brightness == Brightness.dark
        ? 'assets/brand/space_clean_logo_white.svg'
        : 'assets/brand/space_clean_logo.svg',
    height: height,
    semanticsLabel: 'Space Clean',
  );
}
