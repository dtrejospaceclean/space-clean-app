import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../../l10n/app_localizations.dart';
import '../tokens.dart';
import 'cards.dart';
import 'space_page.dart';

/// The shape of the page a [SkeletonSlivers] stands in for.
enum SkeletonLayout {
  /// Rows in one card: lists.
  list,

  /// A head card and a card of facts: detail pages.
  detail,

  /// A card of labeled fields: forms waiting for what they edit.
  form,
}

/// A light sweep over [child]'s placeholder shapes ([SkeletonBone]s), read
/// as "Loading…". Only the shapes shimmer, so wrap the bones inside a card,
/// not the card. Holds still when the OS asks for reduced motion.
class Shimmering extends StatelessWidget {
  const Shimmering({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Semantics(
      label: AppLocalizations.of(context).loadingLabel,
      liveRegion: true,
      excludeSemantics: true,
      child: Shimmer.fromColors(
        baseColor: colors.line,
        // A lighter band on both themes: toward the card on light, toward
        // the ink on dark.
        highlightColor: dark
            ? Color.lerp(colors.line, colors.ink, 0.12)!
            : colors.sunken,
        enabled: !MediaQuery.disableAnimationsOf(context),
        child: child,
      ),
    );
  }
}

/// One placeholder shape: a rounded bar for a line of text, or a circle
/// for an avatar. Must sit inside [Shimmering].
class SkeletonBone extends StatelessWidget {
  const SkeletonBone({super.key, this.width, this.height = 12, this.radius = 6})
    : circle = false;

  const SkeletonBone.circle({super.key, required double size})
    : width = size,
      height = size,
      radius = 0,
      circle = true;

  /// Null fills the width available.
  final double? width;
  final double height;
  final double radius;
  final bool circle;

  @override
  Widget build(BuildContext context) => Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      // Any opaque color: the shimmer paints over it.
      color: context.colors.line,
      shape: circle ? BoxShape.circle : BoxShape.rectangle,
      borderRadius: circle ? null : BorderRadius.circular(radius),
    ),
  );
}

/// A [ListCard] of [rows] placeholder rows (avatar, title, subtitle).
class SkeletonListCard extends StatelessWidget {
  const SkeletonListCard({super.key, this.rows = 6, this.leading = true});

  final int rows;

  /// Whether rows start with a badge or avatar.
  final bool leading;

  /// Varied title widths, so the rows don't read as one block.
  static const _widths = [0.62, 0.48, 0.7, 0.54, 0.66, 0.42];

  @override
  Widget build(BuildContext context) {
    return SpaceCard(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Shimmering(
        child: Column(
          children: [
            for (var i = 0; i < rows; i++)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: SpaceSpace.card,
                  vertical: 14,
                ),
                child: Row(
                  children: [
                    if (leading) ...[
                      const SkeletonBone.circle(size: 40),
                      const SizedBox(width: 14),
                    ],
                    Expanded(
                      child: FractionallySizedBox(
                        alignment: AlignmentDirectional.centerStart,
                        widthFactor: _widths[i % _widths.length],
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SkeletonBone(height: 14),
                            SizedBox(height: 8),
                            FractionallySizedBox(
                              widthFactor: 0.7,
                              child: SkeletonBone(height: 10),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// What a page looks like while its first load runs, laid out as
/// [layout], in place of a spinner.
class SkeletonSlivers extends StatelessWidget {
  const SkeletonSlivers({super.key, this.layout = SkeletonLayout.list});

  final SkeletonLayout layout;

  @override
  Widget build(BuildContext context) => switch (layout) {
    SkeletonLayout.list => const PageBox(top: 4, child: SkeletonListCard()),
    SkeletonLayout.detail => const SliverMainAxisGroup(
      slivers: [
        PageBox(top: 4, child: _HeadCard()),
        PageBox(child: _FactsCard()),
      ],
    ),
    SkeletonLayout.form => const PageBox(top: 4, child: _FieldsCard()),
  };
}

/// A detail page's head card: title, a pill, two lines.
class _HeadCard extends StatelessWidget {
  const _HeadCard();

  @override
  Widget build(BuildContext context) => const SpaceCard(
    child: Shimmering(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FractionallySizedBox(
            widthFactor: 0.65,
            child: SkeletonBone(height: 22, radius: 8),
          ),
          SizedBox(height: 12),
          SkeletonBone(width: 84, height: 24, radius: SpaceRadius.pill),
          SizedBox(height: 16),
          SkeletonBone(),
          SizedBox(height: 8),
          FractionallySizedBox(widthFactor: 0.8, child: SkeletonBone()),
        ],
      ),
    ),
  );
}

/// A detail page's facts: label-over-value pairs, two to a row.
class _FactsCard extends StatelessWidget {
  const _FactsCard();

  @override
  Widget build(BuildContext context) {
    Widget fact() => const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FractionallySizedBox(widthFactor: 0.5, child: SkeletonBone(height: 10)),
        SizedBox(height: 8),
        FractionallySizedBox(widthFactor: 0.8, child: SkeletonBone()),
      ],
    );
    return SpaceCard(
      child: Shimmering(
        child: Column(
          children: [
            for (var i = 0; i < 3; i++) ...[
              if (i > 0) const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(child: fact()),
                  const SizedBox(width: 16),
                  Expanded(child: fact()),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// A form's card: four labels over fields.
class _FieldsCard extends StatelessWidget {
  const _FieldsCard();

  @override
  Widget build(BuildContext context) => SpaceCard(
    child: Shimmering(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < 4; i++) ...[
            if (i > 0) const SizedBox(height: 18),
            const FractionallySizedBox(
              widthFactor: 0.3,
              child: SkeletonBone(height: 10),
            ),
            const SizedBox(height: 8),
            const SkeletonBone(height: 48, radius: SpaceRadius.inner),
          ],
        ],
      ),
    ),
  );
}
