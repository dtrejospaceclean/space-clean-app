import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../error/failures.dart';
import '../../l10n/failure_messages.dart';
import '../../../l10n/app_localizations.dart';
import '../tokens.dart';

/// Loading, error and data states of an [AsyncValue] as slivers. Keeps the
/// previous data on screen while a refresh is running.
class AsyncSlivers<T> extends StatelessWidget {
  const AsyncSlivers({
    super.key,
    required this.value,
    required this.onRetry,
    required this.builder,
  });

  final AsyncValue<T> value;
  final VoidCallback onRetry;
  final Widget Function(T data) builder;

  @override
  Widget build(BuildContext context) {
    if (value.hasValue) return builder(value.requireValue);
    if (value.hasError) {
      final l10n = AppLocalizations.of(context);
      return MessageSliver(
        icon: Icons.cloud_off_rounded,
        title: switch (value.error) {
          final Failure failure => l10n.failureMessage(failure),
          _ => l10n.errorsUnknown,
        },
        action: TextButton(onPressed: onRetry, child: Text(l10n.retryButton)),
      );
    }
    return const SliverFillRemaining(
      hasScrollBody: false,
      child: Center(child: CircularProgressIndicator.adaptive()),
    );
  }
}

/// Centered badge, title and hint for empty and error states.
class MessageSliver extends StatelessWidget {
  const MessageSliver({
    super.key,
    required this.icon,
    required this.title,
    this.hint,
    this.action,
  });

  final IconData icon;
  final String title;
  final String? hint;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: SpaceColors.surface,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 32, color: SpaceColors.accent),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge,
            ),
            if (hint != null) ...[
              const SizedBox(height: 6),
              Text(
                hint!,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium,
              ),
            ],
            if (action != null) ...[const SizedBox(height: 12), action!],
          ],
        ),
      ),
    );
  }
}
