import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../error/failures.dart';
import '../../l10n/failure_messages.dart';
import '../../../l10n/app_localizations.dart';
import '../adaptive.dart';

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
        icon: useCupertino(context)
            ? CupertinoIcons.wifi_exclamationmark
            : Icons.cloud_off_outlined,
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

/// Centered icon, title and hint for empty and error states.
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
            Icon(icon, size: 48, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            if (hint != null) ...[
              const SizedBox(height: 8),
              Text(
                hint!,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            if (action != null) ...[const SizedBox(height: 16), action!],
          ],
        ),
      ),
    );
  }
}
