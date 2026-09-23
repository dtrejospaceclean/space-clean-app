import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/threshold_palette.dart';

/// Oversized text field for the threshold screens: label above, 64-dp
/// field, errors in bold below the field.
class ThresholdField extends StatelessWidget {
  const ThresholdField({
    super.key,
    required this.label,
    required this.controller,
    this.focusNode,
    this.labelAction,
    this.hint,
    this.errorText,
    this.suffix,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.inputFormatters,
    this.obscureText = false,
    this.enabled = true,
    this.autofocus = false,
    this.validator,
    this.onChanged,
    this.onFieldSubmitted,
  });

  final String label;
  final TextEditingController controller;
  final FocusNode? focusNode;

  /// A small action on the label row, e.g. "Not you?".
  final Widget? labelAction;
  final String? hint;

  /// A server-side error, shown like a validator error.
  final String? errorText;
  final Widget? suffix;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final List<TextInputFormatter>? inputFormatters;
  final bool obscureText;
  final bool enabled;
  final bool autofocus;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onFieldSubmitted;

  @override
  Widget build(BuildContext context) {
    final palette = ThresholdPalette.of(context);
    final textTheme = Theme.of(context).textTheme;
    OutlineInputBorder border(Color color, double width) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: color, width: width),
    );

    return MergeSemantics(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ConstrainedBox(
            // Grows with large text instead of clipping.
            constraints: const BoxConstraints(minHeight: 48),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: textTheme.titleMedium?.copyWith(
                      color: palette.onGround,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                ?labelAction,
              ],
            ),
          ),
          TextFormField(
            controller: controller,
            focusNode: focusNode,
            enabled: enabled,
            autofocus: autofocus,
            obscureText: obscureText,
            keyboardType: keyboardType,
            textInputAction: textInputAction,
            autofillHints: autofillHints,
            inputFormatters: inputFormatters,
            autocorrect: false,
            enableSuggestions: !obscureText,
            validator: validator,
            onChanged: onChanged,
            onFieldSubmitted: onFieldSubmitted,
            cursorColor: palette.fieldFocus,
            style: textTheme.bodyLarge?.copyWith(
              color: palette.fieldText,
              fontSize: 18,
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: palette.field,
              hintText: hint,
              hintStyle: TextStyle(color: palette.fieldHint, fontSize: 18),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 21,
              ),
              suffixIcon: suffix,
              suffixIconColor: palette.fieldHint,
              border: border(palette.fieldBorder, 1.5),
              enabledBorder: border(palette.fieldBorder, 1.5),
              disabledBorder: border(palette.fieldBorder, 1.5),
              focusedBorder: border(palette.fieldFocus, 3),
              // Same color as the message: red on white, white on ember
              // (red on ember is under 3:1).
              errorBorder: border(palette.fieldError, 3),
              focusedErrorBorder: border(palette.fieldError, 3),
              errorText: errorText,
              errorMaxLines: 3,
              errorStyle: TextStyle(
                color: palette.fieldError,
                fontSize: 15,
                fontWeight: FontWeight.w700,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
