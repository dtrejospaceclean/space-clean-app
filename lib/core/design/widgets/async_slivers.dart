import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../error/failures.dart';
import '../../l10n/failure_messages.dart';
import '../../../l10n/app_localizations.dart';
import '../tokens.dart';
import 'buttons.dart';
import 'skeleton.dart';

/// Loading, error and data states of an [AsyncValue] as slivers. The first
/// load shows a shimmering [skeleton] of the page. Keeps the previous data
/// on screen while a refresh is running, and the error (with a busy Retry)
/// while a retry is.
class AsyncSlivers<T> extends StatelessWidget {
  const AsyncSlivers({
    super.key,
    required this.value,
    required this.onRetry,
    required this.builder,
    this.skeleton = SkeletonLayout.list,
  });

  final AsyncValue<T> value;
  final SkeletonLayout skeleton;
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
        action: RetryButton(onRetry: onRetry, loading: value.isLoading),
      );
    }
    return SkeletonSlivers(layout: skeleton);
  }
}

/// "Try again" for a failed load. Shows a spinner while [loading] and for a
/// moment after every tap, so a retry that fails again at once (offline)
/// still visibly ran. [primary] makes it the screen's main button.
class RetryButton extends StatefulWidget {
  const RetryButton({
    super.key,
    required this.onRetry,
    this.loading = false,
    this.primary = false,
  });

  final VoidCallback onRetry;
  final bool loading;
  final bool primary;

  @override
  State<RetryButton> createState() => _RetryButtonState();
}

class _RetryButtonState extends State<RetryButton> {
  static const _minBusy = Duration(milliseconds: 700);

  Timer? _timer;

  bool get _busy => widget.loading || (_timer?.isActive ?? false);

  void _retry() {
    setState(() => _timer = Timer(_minBusy, () => setState(() {})));
    widget.onRetry();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final label = AppLocalizations.of(context).retryButton;
    if (widget.primary) {
      return PrimaryButton(label: label, busy: _busy, onPressed: _retry);
    }
    return Semantics(
      button: true,
      enabled: !_busy,
      label: label,
      excludeSemantics: true,
      child: TextButton(
        onPressed: _busy ? null : _retry,
        child: _busy
            ? SizedBox.square(
                dimension: 20,
                child: CircularProgressIndicator.adaptive(strokeWidth: 2.5),
              )
            : Text(label),
      ),
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
              decoration: BoxDecoration(
                color: context.colors.surface,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 32, color: context.colors.accent),
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
