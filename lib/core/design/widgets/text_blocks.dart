import 'package:flutter/material.dart';

import '../tokens.dart';

/// Two-tone headline: a black first line, a softer second line
/// ("You are on top / of your finances").
class HeroHeadline extends StatelessWidget {
  const HeroHeadline({super.key, required this.primary, this.secondary});

  final String primary;
  final String? secondary;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.headlineMedium;
    return Semantics(
      header: true,
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(text: primary),
            if (secondary != null)
              TextSpan(
                text: '\n$secondary',
                style: TextStyle(color: context.colors.inkSoft),
              ),
          ],
        ),
        style: style,
      ),
    );
  }
}

/// "Your activity ........ See all".
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 4),
      child: Row(
        children: [
          Expanded(
            child: Semantics(
              header: true,
              child: Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          if (actionLabel != null)
            TextButton(
              onPressed: onAction,
              style: TextButton.styleFrom(
                foregroundColor: context.colors.inkMuted,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                textStyle: const TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              child: Text(actionLabel!),
            )
          else
            const SizedBox(height: 48),
        ],
      ),
    );
  }
}
