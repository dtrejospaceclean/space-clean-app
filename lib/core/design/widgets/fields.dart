import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../l10n/app_localizations.dart';
import '../tokens.dart';

/// Label above a filled, rounded field. Meant to sit inside a white card
/// (the fill is the card's sunken tone). Errors show in red below.
class SpaceTextField extends StatelessWidget {
  const SpaceTextField({
    super.key,
    required this.label,
    required this.controller,
    this.focusNode,
    this.labelAction,
    this.hint,
    this.helper,
    this.errorText,
    this.suffix,
    this.keyboardType,
    this.textInputAction = TextInputAction.next,
    this.autofillHints,
    this.inputFormatters,
    this.obscureText = false,
    this.enabled = true,
    this.autofocus = false,
    this.textCapitalization = TextCapitalization.none,
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
  final String? helper;

  /// A server-side error, shown like a validator error.
  final String? errorText;
  final Widget? suffix;
  final TextInputType? keyboardType;
  final TextInputAction textInputAction;
  final Iterable<String>? autofillHints;
  final List<TextInputFormatter>? inputFormatters;
  final bool obscureText;
  final bool enabled;
  final bool autofocus;
  final TextCapitalization textCapitalization;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onFieldSubmitted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return MergeSemantics(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 36),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: SpaceColors.ink,
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
            textCapitalization: textCapitalization,
            autocorrect: false,
            enableSuggestions: !obscureText,
            validator: validator,
            onChanged: onChanged,
            onFieldSubmitted: onFieldSubmitted,
            cursorColor: SpaceColors.primary,
            style: const TextStyle(
              fontFamily: 'Manrope',
              fontSize: 17,
              fontWeight: FontWeight.w500,
              color: SpaceColors.ink,
            ),
            decoration: InputDecoration(
              hintText: hint,
              helperText: helper,
              helperMaxLines: 3,
              helperStyle: theme.textTheme.bodySmall?.copyWith(
                color: SpaceColors.inkMuted,
              ),
              errorText: errorText,
              suffixIcon: suffix,
              suffixIconColor: SpaceColors.inkMuted,
            ),
          ),
        ],
      ),
    );
  }
}

/// A field-looking row that opens a picker (dates, single choices).
class PickerField extends StatelessWidget {
  const PickerField({
    super.key,
    required this.label,
    required this.value,
    required this.onTap,
    this.icon = Icons.expand_more_rounded,
  });

  final String label;

  /// `null` shows "Not set".
  final String? value;
  final VoidCallback? onTap;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 36),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(label, style: theme.textTheme.titleSmall),
          ),
        ),
        Semantics(
          button: true,
          label: '$label: ${value ?? l10n.notSet}',
          excludeSemantics: true,
          child: Material(
            color: SpaceColors.sunken,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(SpaceRadius.inner),
              side: const BorderSide(color: SpaceColors.inkSoft),
            ),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 18,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        value ?? l10n.notSet,
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                          color: value == null
                              ? SpaceColors.inkMuted
                              : SpaceColors.ink,
                        ),
                      ),
                    ),
                    Icon(icon, color: SpaceColors.inkMuted),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Multi-select pills: selected ones are orange with a check.
class ChoicePills<T> extends StatelessWidget {
  const ChoicePills({
    super.key,
    required this.options,
    required this.selected,
    required this.onToggle,
  });

  final Map<T, String> options;
  final Set<T> selected;
  final ValueChanged<T>? onToggle;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final MapEntry(:key, :value) in options.entries)
          _Pill(
            label: value,
            selected: selected.contains(key),
            onTap: onToggle == null ? null : () => onToggle!(key),
          ),
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.selected, this.onTap});

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    selected: selected,
    button: true,
    child: Material(
      color: selected ? SpaceColors.primary : SpaceColors.sunken,
      shape: const StadiumBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 44),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (selected) ...[
                  const Icon(
                    Icons.check_rounded,
                    size: 18,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 6),
                ],
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontWeight: FontWeight.w600,
                    fontSize: 14.5,
                    color: selected ? Colors.white : SpaceColors.ink,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

/// A white pill search box with a magnifier, for the top of a list. Pair
/// [onChanged] with a debounce when it hits the server, and set [busy] from
/// the first keystroke until the results are in.
class SearchField extends StatelessWidget {
  const SearchField({
    super.key,
    required this.controller,
    required this.hint,
    required this.onChanged,
    this.busy = false,
  });

  final TextEditingController controller;
  final String hint;
  final ValueChanged<String> onChanged;

  /// Shows a spinner at the end of the box, announced to screen readers.
  final bool busy;

  @override
  Widget build(BuildContext context) {
    OutlineInputBorder border(BorderSide side) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(SpaceRadius.pill),
      borderSide: side,
    );
    return TextField(
      controller: controller,
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: hint,
        fillColor: SpaceColors.surface,
        prefixIcon: const Icon(Icons.search_rounded),
        suffixIcon: busy
            ? Semantics(
                liveRegion: true,
                label: AppLocalizations.of(context).searchingLabel,
                child: const Padding(
                  padding: EdgeInsets.all(14),
                  child: SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator.adaptive(strokeWidth: 2.5),
                  ),
                ),
              )
            : null,
        border: border(BorderSide.none),
        // Same 1px outline as every other input.
        enabledBorder: border(const BorderSide(color: SpaceColors.inkSoft)),
        focusedBorder: border(
          const BorderSide(color: SpaceColors.primary, width: 2),
        ),
      ),
    );
  }
}
