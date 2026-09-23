import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/l10n/failure_messages.dart';
import '../../../../core/theme/threshold_palette.dart';
import '../../../../core/widgets/adaptive.dart';
import '../../../../core/widgets/threshold/brand_block.dart';
import '../../../../core/widgets/threshold/threshold_buttons.dart';
import '../../../../core/widgets/threshold/threshold_notice.dart';
import '../../../../core/widgets/threshold/threshold_scaffold.dart';
import '../../../../l10n/app_localizations.dart';
import '../controllers/auth_controller.dart';

/// Shown while a stored session is being restored at startup.
class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  static const path = '/splash';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final palette = ThresholdPalette.of(context);
    final auth = ref.watch(authControllerProvider);
    final failed = auth.hasError && !auth.isLoading;

    return ThresholdScaffold(
      centerHeader: true,
      header: BrandBlock(tagline: l10n.brandTagline),
      body: failed
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ThresholdNotice(
                  message:
                      '${l10n.splashLoadError} ${switch (auth.error) {
                        final Failure failure => l10n.failureMessage(failure),
                        _ => l10n.errorsUnknown,
                      }}',
                ),
                const SizedBox(height: 24),
                ThresholdButton(
                  label: l10n.retryButton,
                  onPressed: () => ref.invalidate(authControllerProvider),
                ),
              ],
            )
          : SizedBox(
              height: 60,
              child: Center(
                child: useCupertino(context)
                    ? CupertinoActivityIndicator(
                        color: palette.onGround,
                        radius: 14,
                      )
                    : CircularProgressIndicator(color: palette.onGround),
              ),
            ),
    );
  }
}
