import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../tokens.dart';
import 'list_card.dart';

/// Whether text is large enough (150% and up) that side-by-side facts would
/// crowd; they stack one to a row instead.
bool _largeText(BuildContext context) =>
    MediaQuery.textScalerOf(context).scale(1) >= 1.5;

/// A small, letter-spaced capitals label: a section's title above its card
/// ("CONTRACT SCHEDULE & TERMS"), or with [header] false a plain caption
/// inside one ("CONTRACT VALUE").
class CapsHeader extends StatelessWidget {
  const CapsHeader(this.text, {super.key, this.header = true});

  final String text;

  /// A section title: read out as a heading, with room around it.
  final bool header;

  @override
  Widget build(BuildContext context) {
    final label = Text(
      text.toUpperCase(),
      style: TextStyle(
        fontFamily: 'Manrope',
        fontSize: 13,
        fontWeight: FontWeight.w700,
        letterSpacing: 1,
        color: context.colors.inkMuted,
      ),
    );
    if (!header) return label;
    return Padding(
      padding: const EdgeInsets.only(left: 4, top: 6, bottom: 10),
      child: Semantics(header: true, child: label),
    );
  }
}

/// A muted label over its value, bold. A missing value says "Not set",
/// muted, instead of posing as data.
class Fact extends StatelessWidget {
  const Fact({super.key, required this.label, required this.value});

  final String label;

  /// Null when not set.
  final String? value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final value = this.value;
    return MergeSemantics(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: context.colors.inkMuted,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value ?? AppLocalizations.of(context).notSet,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: value == null ? FontWeight.w500 : FontWeight.w700,
              color: value == null ? context.colors.inkMuted : null,
            ),
          ),
        ],
      ),
    );
  }
}

/// [Fact]s in a white card, up to two to a row with hairlines between
/// rows; one to a row at large text.
class FactCard extends StatelessWidget {
  const FactCard({super.key, required this.rows});

  /// Each row's facts: label and value (null when not set). Give long
  /// values (notes, instructions) a row of their own.
  final List<List<(String, String?)>> rows;

  @override
  Widget build(BuildContext context) {
    final lines = _largeText(context)
        ? [
            for (final row in rows)
              for (final fact in row) [fact],
          ]
        : rows;
    return ListCard(
      children: [
        for (final row in lines)
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: SpaceSpace.card,
              vertical: 12,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final (i, (label, value)) in row.indexed) ...[
                  if (i > 0) const SizedBox(width: 16),
                  Expanded(
                    child: Fact(label: label, value: value),
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }
}

/// A [Fact] as a row in a [ListCard] that opens a related page, with a
/// chevron when it can.
class FactRow extends StatelessWidget {
  const FactRow({
    super.key,
    required this.label,
    required this.value,
    this.onTap,
  });

  final String label;
  final String? value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 60),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: SpaceSpace.card,
          vertical: 12,
        ),
        child: Row(
          children: [
            Expanded(
              child: Fact(label: label, value: value),
            ),
            if (onTap != null) ...[
              const SizedBox(width: 8),
              Icon(Icons.chevron_right_rounded, color: context.colors.inkSoft),
            ],
          ],
        ),
      ),
    ),
  );
}
