import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design/design.dart';
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
    final failed = auth.hasError && !auth.isLoading;

    return Scaffold(
      backgroundColor: context.colors.ground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(SpaceSpace.page),
          child: Column(
            children: [
              const Spacer(),
              const SpaceLogo(height: 132),
              const SizedBox(height: 20),
              Text(
                l10n.brandTagline,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const Spacer(),
              if (failed) ...[
                Notice(
                  message:
                      '${l10n.splashLoadError} ${switch (auth.error) {
                        final Failure failure => l10n.failureMessage(failure),
                        _ => l10n.errorsUnknown,
                      }}',
                ),
                const SizedBox(height: 16),
                PrimaryButton(
                  label: l10n.retryButton,
                  onPressed: () => ref.invalidate(authControllerProvider),
                ),
              ] else
                const SizedBox(
                  height: 56,
                  child: Center(child: CircularProgressIndicator.adaptive()),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
