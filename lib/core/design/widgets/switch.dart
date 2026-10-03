import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../tokens.dart';

/// An on/off switch, the same on both platforms. On is a Primary Orange
/// track with a white thumb carrying a check; off is a sunken track with a
/// Soft Ink outline and a smaller Soft Ink thumb. Position, thumb size and
/// the check all change, so the state never rests on color alone.
///
/// Visual only: put it in a [SwitchRow], which owns the tap target and what
/// screen readers hear.
class SpaceSwitch extends StatelessWidget {
  const SpaceSwitch({super.key, required this.value, this.enabled = true});

  final bool value;
  final bool enabled;

  static const _width = 52.0;
  static const _height = 32.0;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : const Duration(milliseconds: 180);
    const curve = Curves.easeOutCubic;
    final thumb = value ? 24.0 : 16.0;
    final Color track;
    final Color outline;
    final Color thumbColor;
    if (!enabled) {
      track = value ? c.inkFaint : c.sunken;
      outline = value ? c.inkFaint : c.line;
      thumbColor = value ? c.surface : c.inkFaint;
    } else {
      track = value ? c.primary : c.sunken;
      outline = value ? c.primary : c.inkSoft;
      thumbColor = value ? c.onPrimary : c.inkSoft;
    }
    return AnimatedContainer(
      duration: duration,
      curve: curve,
      width: _width,
      height: _height,
      decoration: ShapeDecoration(
        color: track,
        shape: StadiumBorder(side: BorderSide(color: outline)),
      ),
      child: AnimatedAlign(
        duration: duration,
        curve: curve,
        alignment: value
            ? AlignmentDirectional.centerEnd.resolve(Directionality.of(context))
            : AlignmentDirectional.centerStart.resolve(
                Directionality.of(context),
              ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: value ? 3 : 7),
          child: AnimatedContainer(
            duration: duration,
            curve: curve,
            width: thumb,
            height: thumb,
            decoration: ShapeDecoration(
              color: thumbColor,
              shape: const CircleBorder(),
            ),
            child: AnimatedOpacity(
              duration: duration,
              opacity: value ? 1 : 0,
              child: Icon(
                Icons.check_rounded,
                size: 16,
                color: enabled ? c.primary : c.inkFaint,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A full-width row that turns something on or off: a label on the left and
/// a [SpaceSwitch] on the right. The whole row is the target (at least 52
/// tall, for gloves). Without [onChanged] the row shows its state as a mark
/// instead of a switch, so a read-only list never looks pressable.
class SwitchRow extends StatelessWidget {
  const SwitchRow({
    super.key,
    required this.label,
    required this.value,
    this.onChanged,
    this.readOnly = false,
  });

  final String label;
  final bool value;

  /// Null disables the switch (while saving, say).
  final ValueChanged<bool>? onChanged;

  /// Shows the state as a check or a dash rather than a switch.
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final enabled = !readOnly && onChanged != null;
    final text = Text(
      label,
      style: TextStyle(
        fontFamily: 'Manrope',
        fontSize: 14.5,
        fontWeight: FontWeight.w500,
        color: readOnly && !value ? c.inkMuted : c.ink,
      ),
    );
    final row = ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 52),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Expanded(child: text),
            const SizedBox(width: 12),
            if (readOnly)
              Icon(
                value
                    ? Icons.check_circle_rounded
                    : Icons.remove_circle_outline_rounded,
                size: 22,
                color: value ? c.accent : c.inkMuted,
              )
            else
              SpaceSwitch(value: value, enabled: enabled),
          ],
        ),
      ),
    );
    if (readOnly) {
      return MergeSemantics(
        child: Semantics(checked: value, child: row),
      );
    }
    return MergeSemantics(
      child: Semantics(
        toggled: value,
        enabled: enabled,
        child: InkWell(
          borderRadius: BorderRadius.circular(SpaceRadius.inner),
          onTap: enabled
              ? () {
                  HapticFeedback.selectionClick();
                  onChanged!(!value);
                }
              : null,
          child: row,
        ),
      ),
    );
  }
}
