import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/threshold_palette.dart';
import '../../../../core/widgets/adaptive.dart';
import '../../../../core/widgets/threshold/threshold_buttons.dart';
import '../../../../core/widgets/threshold/threshold_scaffold.dart';
import '../../../../l10n/app_localizations.dart';
import '../controllers/password_reset_controller.dart';

/// The reset worked: back to sign-in with the email filled in.
class ResetDoneScreen extends ConsumerWidget {
  const ResetDoneScreen({super.key});

  static const path = '/login/forgot/done';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final palette = ThresholdPalette.of(context);
    final email = ref.watch(passwordResetControllerProvider).email;

    return ThresholdScaffold(
      centerHeader: true,
      header: Column(
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: palette.onGround,
              shape: BoxShape.circle,
            ),
            child: Icon(
              useCupertino(context)
                  ? CupertinoIcons.checkmark_alt
                  : Icons.check,
              size: 56,
              color: palette.ground,
            ),
          ),
          const SizedBox(height: 28),
          Semantics(
            header: true,
            child: Text(
              l10n.resetDoneTitle,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: palette.onGround,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.resetDoneBody,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge
                ?.copyWith(color: palette.onGroundMuted, fontSize: 17),
          ),
        ],
      ),
      body: ThresholdButton(
        label: l10n.backToSignIn,
        onPressed: () => context.go(
          Uri(
            path: '/login',
            queryParameters: {if (email.isNotEmpty) 'email': email},
          ).toString(),
        ),
      ),
    );
  }
}
