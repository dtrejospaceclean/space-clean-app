import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/threshold_palette.dart';

/// Six large digit boxes over one invisible text field, so paste and the
/// OS one-time-code autofill (SMS / email suggestions) fill every box at once.
class CodeInput extends StatefulWidget {
  const CodeInput({
    super.key,
    required this.controller,
    required this.label,
    this.length = 6,
    this.errorText,
    this.enabled = true,
    this.onCompleted,
  });

  final TextEditingController controller;
  final String label;
  final int length;
  final String? errorText;
  final bool enabled;
  final ValueChanged<String>? onCompleted;

  @override
  State<CodeInput> createState() => _CodeInputState();
}

class _CodeInputState extends State<CodeInput> {
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _focus.addListener(_rebuild);
    widget.controller.addListener(_rebuild);
  }

  @override
  void dispose() {
    _focus.dispose();
    widget.controller.removeListener(_rebuild);
    super.dispose();
  }

  void _rebuild() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final palette = ThresholdPalette.of(context);
    final textTheme = Theme.of(context).textTheme;
    final code = widget.controller.text;
    final hasError = widget.errorText != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ConstrainedBox(
          // Grows with large text instead of clipping.
          constraints: const BoxConstraints(minHeight: 48),
          child: Align(
            alignment: Alignment.centerLeft,
            child: ExcludeSemantics(
              child: Text(
                widget.label,
                style: textTheme.titleMedium?.copyWith(
                  color: palette.onGround,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
        SizedBox(
          height: 68,
          child: Stack(
            children: [
              ExcludeSemantics(
                child: Row(
                  children: [
                    for (var i = 0; i < widget.length; i++) ...[
                      if (i > 0) const SizedBox(width: 8),
                      Expanded(
                        child: _Box(
                          digit: i < code.length ? code[i] : '',
                          active:
                              _focus.hasFocus &&
                              (i == code.length ||
                                  (i == widget.length - 1 &&
                                      code.length == widget.length)),
                          error: hasError,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Positioned.fill(
                child: Opacity(
                  opacity: 0,
                  child: TextField(
                    controller: widget.controller,
                    focusNode: _focus,
                    enabled: widget.enabled,
                    autofocus: true,
                    showCursor: false,
                    enableInteractiveSelection: false,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.done,
                    autofillHints: const [AutofillHints.oneTimeCode],
                    maxLength: widget.length,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration.collapsed(
                      hintText: widget.label,
                    ).copyWith(counterText: ''),
                    onChanged: (value) {
                      if (value.length == widget.length) {
                        widget.onCompleted?.call(value);
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 8),
          Text(
            widget.errorText!,
            style: TextStyle(
              color: palette.fieldError,
              fontSize: 15,
              fontWeight: FontWeight.w700,
              height: 1.35,
            ),
          ),
        ],
      ],
    );
  }
}

class _Box extends StatelessWidget {
  const _Box({required this.digit, required this.active, required this.error});

  final String digit;
  final bool active;
  final bool error;

  @override
  Widget build(BuildContext context) {
    final palette = ThresholdPalette.of(context);
    final (color, width) = error
        ? (palette.fieldError, 3.0)
        : active
        ? (palette.fieldFocus, 3.0)
        : (palette.fieldBorder, 1.5);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: palette.field,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: width),
      ),
      alignment: Alignment.center,
      child: Text(
        digit,
        style: TextStyle(
          color: palette.fieldText,
          fontSize: 30,
          fontWeight: FontWeight.w700,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
    );
  }
}
