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
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: isSelected
                          ? context.colors.onPrimary
                          : context.colors.inkMuted,
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
