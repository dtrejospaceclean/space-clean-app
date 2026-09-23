import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Dates and times in the app's language and the phone's 12/24-hour setting.
extension DateFormatting on BuildContext {
  String get _locale => Localizations.localeOf(this).toLanguageTag();

  /// "7:00 AM" / "07:00".
  String formatTime(DateTime time) =>
      MaterialLocalizations.of(this).formatTimeOfDay(
        TimeOfDay.fromDateTime(time),
        alwaysUse24HourFormat: MediaQuery.alwaysUse24HourFormatOf(this),
      );

  /// "7:00 – 9:00 AM" style range; the end is optional.
  String formatTimeRange(DateTime start, DateTime? end) => end == null
      ? formatTime(start)
      : '${formatTime(start)} – ${formatTime(end)}';

  /// "Wednesday, September 23".
  String formatDayLong(DateTime day) =>
      DateFormat.MMMMEEEEd(_locale).format(day);
}
