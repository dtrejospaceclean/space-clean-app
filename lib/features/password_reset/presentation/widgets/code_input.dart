import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/design/design.dart';

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
    final code = widget.controller.text;
    final hasError = widget.errorText != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 36),
          child: Align(
            alignment: Alignment.centerLeft,
            child: ExcludeSemantics(
              child: Text(
                widget.label,
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
          ),
        ),
        SizedBox(
          height: 64,
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
                    ).copyWith(counterText: '', filled: false),
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
            style: const TextStyle(
              fontFamily: 'Manrope',
              color: SpaceColors.danger,
              fontSize: 13,
              fontWeight: FontWeight.w600,
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
    final border = error
        ? Border.all(color: SpaceColors.danger, width: 2)
        : active
        ? Border.all(color: SpaceColors.accent, width: 2)
        : Border.all(color: SpaceColors.inkSoft);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: SpaceColors.sunken,
        borderRadius: BorderRadius.circular(SpaceRadius.inner),
        border: border,
      ),
      alignment: Alignment.center,
      child: Text(
        digit,
        style: const TextStyle(
          fontFamily: 'Manrope',
          color: SpaceColors.ink,
          fontSize: 28,
          fontWeight: FontWeight.w800,
          fontFeatures: [FontFeature.tabularFigures()],
        ),
      ),
    );
  }
}
