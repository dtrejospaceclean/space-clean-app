import 'package:flutter/material.dart';

import '../../../../core/design/design.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/proposal.dart';

extension ProposalStageNames on AppLocalizations {
  String proposalStage(ProposalStage stage) => switch (stage) {
    ProposalStage.lead => proposalStageLead,
    ProposalStage.walkthrough => proposalStageWalkthrough,
    ProposalStage.pricing => proposalStagePricing,
    ProposalStage.proposal => proposalStageProposal,
    ProposalStage.negotiation => proposalStageNegotiation,
    ProposalStage.approved => proposalStageApproved,
    ProposalStage.unknown => proposalStageUnknown,
  };
}

/// The stage as a tinted pill with an icon, so it never depends on color
/// alone: open stages in navy, negotiation in orange, approved in green.
class ProposalStageLabel extends StatelessWidget {
  const ProposalStageLabel({super.key, required this.stage});

  final ProposalStage stage;

  @override
  Widget build(BuildContext context) {
    final (IconData icon, Color color, Color background) = switch (stage) {
      ProposalStage.approved => (
        Icons.check_rounded,
        context.colors.successInk,
        context.colors.successSoft,
      ),
      ProposalStage.negotiation => (
        Icons.handshake_outlined,
        context.colors.highlightInk,
        context.colors.highlightSoft,
      ),
      ProposalStage.unknown => (
        Icons.help_outline_rounded,
        context.colors.inkMuted,
        context.colors.sunken,
      ),
      _ => (
        Icons.trending_flat_rounded,
        context.colors.accent,
        context.colors.accentSoft,
      ),
    };
    return StatusPill(
      label: AppLocalizations.of(context).proposalStage(stage),
      icon: icon,
      color: color,
      background: background,
    );
  }
}
