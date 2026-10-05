import 'package:flutter/material.dart';

import '../../../../core/design/design.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/contract.dart';

extension ContractStatusNames on AppLocalizations {
  String contractStatus(ContractStatus status) => switch (status) {
    ContractStatus.draft => contractStatusDraft,
    ContractStatus.active => contractStatusActive,
    ContractStatus.expired => contractStatusExpired,
    ContractStatus.cancelled => contractStatusCancelled,
    ContractStatus.unknown => contractStatusUnknown,
  };
}

/// The status as a tinted pill with an icon, so it never depends on color
/// alone: draft in navy, active in green, expiring soon in orange, expired
/// and cancelled muted and red.
class ContractStatusLabel extends StatelessWidget {
  const ContractStatusLabel({super.key, required this.contract});

  final Contract contract;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final (
      String label,
      IconData icon,
      Color color,
      Color background,
    ) = switch (contract.status) {
      _ when contract.isExpiringSoon => (
        l10n.contractExpiringSoon,
        Icons.schedule_rounded,
        c.highlightInk,
        c.highlightSoft,
      ),
      ContractStatus.active => (
        l10n.contractStatusActive,
        Icons.check_rounded,
        c.successInk,
        c.successSoft,
      ),
      ContractStatus.draft => (
        l10n.contractStatusDraft,
        Icons.edit_note_rounded,
        c.accent,
        c.accentSoft,
      ),
      ContractStatus.cancelled => (
        l10n.contractStatusCancelled,
        Icons.block_rounded,
        c.danger,
        c.dangerSoft,
      ),
      final status => (
        l10n.contractStatus(status),
        status == ContractStatus.expired
            ? Icons.event_busy_outlined
            : Icons.help_outline_rounded,
        c.inkMuted,
        c.sunken,
      ),
    };
    return StatusPill(
      label: label,
      icon: icon,
      color: color,
      background: background,
    );
  }
}
