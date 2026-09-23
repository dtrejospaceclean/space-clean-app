import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/l10n/failure_messages.dart';
import '../../../../l10n/app_localizations.dart';
import '../controllers/auth_controller.dart';

/// Shown while a stored session is being restored at startup.
class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  static const path = '/splash';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final auth = ref.watch(authControllerProvider);

    return Scaffold(
      body: Center(
        child: auth.hasError && !auth.isLoading
            ? Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(l10n.splashLoadError, textAlign: TextAlign.center),
                    const SizedBox(height: 8),
                    Text(
                      switch (auth.error) {
                        final Failure failure => l10n.failureMessage(failure),
                        _ => l10n.errorsUnknown,
                      },
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () => ref.invalidate(authControllerProvider),
                      child: Text(l10n.retryButton),
                    ),
                  ],
                ),
              )
            : const CircularProgressIndicator(),
      ),
    );
  }
}
