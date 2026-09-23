import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../l10n/app_localizations.dart';
import '../adaptive.dart';

/// A titled group of form fields: an inset-grouped form section on iOS, a
/// padded column with a small header on Android.
class AppFormSection extends StatelessWidget {
  const AppFormSection({
    super.key,
    this.title,
    this.footer,
    required this.children,
  });

  final String? title;
  final String? footer;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    if (useCupertino(context)) {
      // Derived from the Cupertino text theme so the system font carries.
      final small = CupertinoTheme.of(context).textTheme.textStyle.copyWith(
        fontSize: 13,
        color: CupertinoColors.secondaryLabel.resolveFrom(context),
      );
      return CupertinoFormSection.insetGrouped(
        header: title == null ? null : Text(title!.toUpperCase(), style: small),
        footer: footer == null ? null : Text(footer!, style: small),
        children: children,
      );
    }
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (title != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                title!,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          for (final child in children)
            Padding(padding: const EdgeInsets.only(bottom: 12), child: child),
          if (footer != null)
            Text(
              footer!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
        ],
      ),
    );
  }
}

/// A validated text field in the platform's form style.
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.validator,
    this.keyboardType,
    this.textInputAction = TextInputAction.next,
    this.autofillHints,
    this.inputFormatters,
    this.obscureText = false,
    this.enabled = true,
    this.textCapitalization = TextCapitalization.none,
  });

  final String label;
  final TextEditingController controller;
  final String? hint;
  final FormFieldValidator<String>? validator;
  final TextInputType? keyboardType;
  final TextInputAction textInputAction;
  final Iterable<String>? autofillHints;
  final List<TextInputFormatter>? inputFormatters;
  final bool obscureText;
  final bool enabled;
  final TextCapitalization textCapitalization;

  @override
  Widget build(BuildContext context) {
    if (useCupertino(context)) {
      return CupertinoTextFormFieldRow(
        controller: controller,
        prefix: SizedBox(width: 136, child: Text(label)),
        placeholder: hint,
        validator: validator,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        autofillHints: autofillHints,
        inputFormatters: inputFormatters,
        obscureText: obscureText,
        enabled: enabled,
        textCapitalization: textCapitalization,
        autocorrect: false,
      );
    }
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      autofillHints: autofillHints,
      inputFormatters: inputFormatters,
      obscureText: obscureText,
      enabled: enabled,
      textCapitalization: textCapitalization,
      autocorrect: false,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: const OutlineInputBorder(),
        errorMaxLines: 3,
      ),
    );
  }
}

/// A row that shows a value and opens a picker when tapped.
class AppPickerRow extends StatelessWidget {
  const AppPickerRow({
    super.key,
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;

  /// `null` shows "Not set".
  final String? value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (useCupertino(context)) {
      return CupertinoListTile(
        title: Text(label),
        additionalInfo: Text(value ?? l10n.notSet),
        trailing: onTap == null ? null : const CupertinoListTileChevron(),
        onTap: onTap,
      );
    }
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          suffixIcon: const Icon(Icons.arrow_drop_down),
        ),
        child: Text(value ?? l10n.notSet),
      ),
    );
  }
}

/// Lets the user pick one of [options]; returns the chosen value, or `null`
/// when dismissed. [allowClear] adds a "Clear" choice returning `''`.
Future<String?> showAppChoice(
  BuildContext context, {
  required String title,
  required Map<String, String> options,
  bool allowClear = true,
}) {
  final l10n = AppLocalizations.of(context);
  if (useCupertino(context)) {
    return showCupertinoModalPopup<String>(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: Text(title),
        actions: [
          for (final MapEntry(:key, :value) in options.entries)
            CupertinoActionSheetAction(
              onPressed: () => Navigator.of(context).pop(key),
              child: Text(value),
            ),
          if (allowClear)
            CupertinoActionSheetAction(
              isDestructiveAction: true,
              onPressed: () => Navigator.of(context).pop(''),
              child: Text(l10n.clearButton),
            ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancelButton),
        ),
      ),
    );
  }
  return showModalBottomSheet<String>(
    context: context,
    showDragHandle: true,
    builder: (context) => SafeArea(
      child: ListView(
        shrinkWrap: true,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
            child: Text(title, style: Theme.of(context).textTheme.titleMedium),
          ),
          for (final MapEntry(:key, :value) in options.entries)
            ListTile(
              title: Text(value),
              onTap: () => Navigator.of(context).pop(key),
            ),
          if (allowClear)
            ListTile(
              title: Text(l10n.clearButton),
              onTap: () => Navigator.of(context).pop(''),
            ),
        ],
      ),
    ),
  );
}

/// Picks a calendar date: the Material date dialog on Android, a date wheel
/// in a bottom popup on iOS. Returns `null` when dismissed.
Future<DateTime?> showAppDatePicker(
  BuildContext context, {
  DateTime? initial,
}) async {
  final now = DateTime.now();
  final first = DateTime(1970);
  final last = DateTime(now.year + 1, 12, 31);
  final start = initial ?? DateTime(now.year, now.month, now.day);
  if (!useCupertino(context)) {
    return showDatePicker(
      context: context,
      initialDate: start,
      firstDate: first,
      lastDate: last,
    );
  }
  var picked = start;
  final l10n = AppLocalizations.of(context);
  final done = await showCupertinoModalPopup<bool>(
    context: context,
    builder: (context) => Container(
      height: 300,
      color: CupertinoColors.systemBackground.resolveFrom(context),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: CupertinoButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(l10n.doneButton),
              ),
            ),
            Expanded(
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.date,
                initialDateTime: start,
                minimumDate: first,
                maximumDate: last,
                onDateTimeChanged: (d) => picked = d,
              ),
            ),
          ],
        ),
      ),
    ),
  );
  return done == true ? DateTime(picked.year, picked.month, picked.day) : null;
}

/// A multi-select row: a checkmark on iOS, a checkbox on Android.
class AppCheckRow extends StatelessWidget {
  const AppCheckRow({
    super.key,
    required this.title,
    this.subtitle,
    required this.checked,
    required this.onChanged,
  });

  final String title;
  final String? subtitle;
  final bool checked;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    if (useCupertino(context)) {
      return CupertinoListTile(
        title: Text(title),
        subtitle: subtitle == null ? null : Text(subtitle!),
        trailing: checked
            ? Icon(
                CupertinoIcons.checkmark_alt,
                color: CupertinoTheme.of(context).primaryColor,
              )
            : null,
        onTap: onChanged == null ? null : () => onChanged!(!checked),
      );
    }
    return CheckboxListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title),
      subtitle: subtitle == null ? null : Text(subtitle!),
      value: checked,
      onChanged: onChanged == null ? null : (v) => onChanged!(v ?? false),
    );
  }
}
