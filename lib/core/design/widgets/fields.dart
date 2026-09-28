import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../l10n/app_localizations.dart';
import '../tokens.dart';
import 'cards.dart';
import 'space_page.dart';
import 'text_blocks.dart';

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
    this.maxLines = 1,
    this.minLines,
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

  /// More than 1 (or null, to grow) for free text such as notes.
  final int? maxLines;
  final int? minLines;
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
                      color: context.colors.ink,
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
            maxLines: maxLines,
            minLines: minLines,
            autocorrect: false,
            enableSuggestions: !obscureText,
            validator: validator,
            onChanged: onChanged,
            onFieldSubmitted: onFieldSubmitted,
            cursorColor: context.colors.primary,
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 15.5,
              fontWeight: FontWeight.w500,
              color: context.colors.ink,
            ),
            decoration: InputDecoration(
              hintText: hint,
              helperText: helper,
              helperMaxLines: 3,
              helperStyle: theme.textTheme.bodySmall?.copyWith(
                color: context.colors.inkMuted,
              ),
              errorText: errorText,
              suffixIcon: suffix,
              suffixIconColor: context.colors.inkMuted,
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
    this.errorText,
  });

  final String label;

  /// `null` shows "Not set".
  final String? value;
  final VoidCallback? onTap;
  final IconData icon;

  /// Shown in red below, like a text field's validator error.
  final String? errorText;

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
          label: ['$label: ${value ?? l10n.notSet}', ?errorText].join('. '),
          excludeSemantics: true,
          child: Material(
            color: context.colors.sunken,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(SpaceRadius.inner),
              side: errorText == null
                  ? BorderSide(color: context.colors.inkSoft)
                  : BorderSide(color: context.colors.danger, width: 2),
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
                          fontSize: 15.5,
                          fontWeight: FontWeight.w500,
                          color: value == null
                              ? context.colors.inkMuted
                              : context.colors.ink,
                        ),
                      ),
                    ),
                    Icon(icon, color: context.colors.inkMuted),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (errorText case final error?)
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
            child: Text(error, style: theme.inputDecorationTheme.errorStyle),
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
      color: selected ? context.colors.primary : context.colors.sunken,
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
                  Icon(
                    Icons.check_rounded,
                    size: 18,
                    color: context.colors.onPrimary,
                  ),
                  const SizedBox(width: 6),
                ],
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontWeight: FontWeight.w600,
                    fontSize: 13.5,
                    color: selected
                        ? context.colors.onPrimary
                        : context.colors.ink,
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
        fillColor: context.colors.surface,
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
        enabledBorder: border(BorderSide(color: context.colors.inkSoft)),
        focusedBorder: border(
          BorderSide(color: context.colors.primary, width: 2),
        ),
      ),
    );
  }
}

/// A titled white card of form fields with page margins, as used by every
/// form screen (fields 12 apart, an optional footnote under them).
class FormSection extends StatelessWidget {
  const FormSection(this.title, this.fields, {super.key, this.footer});

  final String title;
  final List<Widget> fields;
  final String? footer;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.fromLTRB(pageSide(context), 12, pageSide(context), 0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(title: title),
        SpaceCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final (i, f) in fields.indexed) ...[
                if (i > 0) const SizedBox(height: 12),
                f,
              ],
              if (footer case final footer?) ...[
                const SizedBox(height: 10),
                Text(footer, style: Theme.of(context).textTheme.bodySmall),
              ],
            ],
          ),
        ),
      ],
    ),
  );
}
