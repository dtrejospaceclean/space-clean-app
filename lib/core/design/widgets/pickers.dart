import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../widgets/adaptive.dart';

// Pickers keep each platform's native behavior (action sheet and date wheel
// on iOS, bottom sheet and date dialog on Android).

/// Lets the user pick one of [options]; returns the chosen value, or `null`
/// when dismissed. [allowClear] adds a "Not set" choice returning `''`.
/// [title] is optional: a menu whose options name themselves needs none.
Future<String?> showAppChoice(
  BuildContext context, {
  String? title,
  required Map<String, String> options,
  bool allowClear = true,
}) {
  final l10n = AppLocalizations.of(context);
  if (useCupertino(context)) {
    return showCupertinoModalPopup<String>(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: title == null ? null : Text(title),
        actions: [
          for (final MapEntry(:key, :value) in options.entries)
            CupertinoActionSheetAction(
              onPressed: () => Navigator.of(context).pop(key),
              child: Text(value),
            ),
          if (allowClear)
            CupertinoActionSheetAction(
              onPressed: () => Navigator.of(context).pop(''),
              child: Text(l10n.notSet),
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
          if (title != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          for (final MapEntry(:key, :value) in options.entries)
            ListTile(
              title: Text(value),
              onTap: () => Navigator.of(context).pop(key),
            ),
          if (allowClear)
            ListTile(
              title: Text(l10n.notSet),
              onTap: () => Navigator.of(context).pop(''),
            ),
        ],
      ),
    ),
  );
}

/// Picks a calendar date: the Material date dialog on Android, a date wheel
/// in a bottom popup on iOS. Returns `null` when dismissed. [last] is the
/// latest selectable day (default: the end of next year).
Future<DateTime?> showAppDatePicker(
  BuildContext context, {
  DateTime? initial,
  DateTime? last,
}) async {
  final now = DateTime.now();
  final first = DateTime(1970);
  last = last == null
      ? DateTime(now.year + 1, 12, 31)
      : DateTime(last.year, last.month, last.day);
  var start = initial ?? DateTime(now.year, now.month, now.day);
  if (start.isAfter(last)) start = last;
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
