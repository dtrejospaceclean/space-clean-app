import 'package:flutter/material.dart';

import '../tokens.dart';

/// Pill-shaped single choice: the selected option is an orange pill with white
/// text on a white (or sunken) track.
class PillToggle<T> extends StatelessWidget {
  const PillToggle({
    super.key,
    required this.options,
    required this.selected,
    required this.onChanged,
    this.semanticLabel,
    this.expand = true,
    this.track,
    this.counts,
  });

  /// Value → label, in display order.
  final Map<T, String> options;
  final T selected;
  final ValueChanged<T> onChanged;
  final String? semanticLabel;

  /// Stretch to the available width, sharing it equally.
  final bool expand;

  /// Defaults to the surface color.
  final Color? track;

  /// A count shown in a bubble after an option's label ("Upcoming  3").
  final Map<T, int>? counts;

  @override
  Widget build(BuildContext context) {
    Widget option(T value, String label) {
      final isSelected = value == selected;
      final chip = Semantics(
        selected: isSelected,
        button: true,
        child: Material(
          color: isSelected ? context.colors.primary : Colors.transparent,
          shape: const StadiumBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: isSelected ? null : () => onChanged(value),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 40, minWidth: 48),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                child: Center(
                  widthFactor: 1,
                  // At large text sizes a label shrinks just enough to show
                  // the whole word; a clipped "Categ…" reads as nothing.
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          label,
                          maxLines: 1,
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            color: isSelected
                                ? context.colors.onPrimary
                                : context.colors.inkMuted,
                          ),
                        ),
                        if (counts?[value] case final count?) ...[
                          const SizedBox(width: 8),
                          _CountBubble(count: count, onPrimary: isSelected),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      return expand ? Expanded(child: chip) : chip;
    }

    return Semantics(
      label: semanticLabel,
      container: true,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: track ?? context.colors.surface,
          borderRadius: BorderRadius.circular(SpaceRadius.pill),
        ),
        child: Row(
          mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
          children: [
            for (final MapEntry(:key, :value) in options.entries)
              option(key, value),
          ],
        ),
      ),
    );
  }
}

/// The count after a toggle option's label: white with orange figures on
/// the orange pill (4.55:1; a see-through white would fall below 4.5:1),
/// hairline gray on the track.
class _CountBubble extends StatelessWidget {
  const _CountBubble({required this.count, required this.onPrimary});

  final int count;
  final bool onPrimary;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      constraints: const BoxConstraints(minWidth: 24),
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: onPrimary ? c.onPrimary : c.line,
        borderRadius: BorderRadius.circular(SpaceRadius.pill),
      ),
      child: Text(
        '$count',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: 'Manrope',
          fontWeight: FontWeight.w700,
          fontSize: 12.5,
          fontFeatures: const [FontFeature.tabularFigures()],
          color: onPrimary ? c.primary : c.inkMuted,
        ),
      ),
    );
  }
}
