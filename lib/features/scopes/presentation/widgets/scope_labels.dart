import 'package:flutter/material.dart';

import '../../../../core/design/design.dart';
import '../../../../core/l10n/formatting.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/scope.dart';

extension ScopeFrequencyNames on AppLocalizations {
  String scopeFrequency(ScopeFrequency f) => switch (f) {
    ScopeFrequency.daily => frequencyDaily,
    ScopeFrequency.weekly => frequencyWeekly,
    ScopeFrequency.biweekly => frequencyBiweekly,
    ScopeFrequency.monthly => frequencyMonthly,
    ScopeFrequency.quarterly => frequencyQuarterly,
    ScopeFrequency.annual => frequencyAnnual,
    ScopeFrequency.oneTime => frequencyOneTime,
    ScopeFrequency.unknown => frequencyUnknown,
  };
}

/// What a scope covers, as a title: its area, else its service, else the
/// whole site.
String scopeTitle(AppLocalizations l10n, Scope s) =>
    switch ((s.areaName?.trim(), s.serviceName)) {
      (final area?, _) when area.isNotEmpty => area,
      (_, final service?) => service,
      _ => l10n.scopeWholeSite,
    };

/// "7:00 – 8:00 AM", or the start alone.
String scheduleTimes(BuildContext context, ScopeSchedule s) {
  String time(ClockTime t) => context.formatClock(t.hour, t.minute);
  return switch (s.endTime) {
    final end? => '${time(s.startTime)} – ${time(end)}',
    null => time(s.startTime),
  };
}

/// "Mon, Wed, Fri", or "Every day" for all seven.
String scheduleDays(BuildContext context, ScopeSchedule s) =>
    s.daysOfWeek.length == 7
    ? AppLocalizations.of(context).everyDay
    : s.daysOfWeek.map(context.formatWeekdayShort).join(', ');

/// "Mon, Wed, Fri · 7:00 – 8:00 AM"; days only when the frequency names
/// them.
String scheduleSummary(
  BuildContext context,
  ScopeFrequency frequency,
  ScopeSchedule s,
) => [
  if (frequency.needsDays && s.daysOfWeek.isNotEmpty) scheduleDays(context, s),
  scheduleTimes(context, s),
].join(' · ');

/// The frequency as a tinted pill with a repeat icon.
class FrequencyLabel extends StatelessWidget {
  const FrequencyLabel({super.key, required this.frequency});

  final ScopeFrequency frequency;

  @override
  Widget build(BuildContext context) => StatusPill(
    label: AppLocalizations.of(context).scopeFrequency(frequency),
    icon: frequency == ScopeFrequency.oneTime
        ? Icons.looks_one_outlined
        : Icons.repeat_rounded,
    color: context.colors.accent,
    background: context.colors.accentSoft,
  );
}
