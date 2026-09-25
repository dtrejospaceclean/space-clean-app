import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design/design.dart';
import '../../../../l10n/app_localizations.dart';
import '../controllers/password_reset_controller.dart';

/// The reset worked: back to sign-in with the email filled in.
class ResetDoneScreen extends ConsumerWidget {
  const ResetDoneScreen({super.key});

  static const path = '/login/forgot/done';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final email = ref.watch(passwordResetControllerProvider).email;

    return SpacePage(
      showBack: false,
      slivers: [
        PageBox(
          top: 48,
          child: SpaceCard(
            child: Column(
              children: [
                const SizedBox(height: 12),
                const IconBadge.strong(icon: Icons.check_rounded, size: 72),
                const SizedBox(height: 24),
                HeroHeadline(primary: l10n.resetDoneTitle),
                const SizedBox(height: 8),
                Text(
                  l10n.resetDoneBody,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge
                      ?.copyWith(color: context.colors.inkMuted),
                ),
                const SizedBox(height: 28),
                PrimaryButton(
                  label: l10n.backToSignIn,
                  onPressed: () => context.go(
                    Uri(
                      path: '/login',
                      queryParameters: {if (email.isNotEmpty) 'email': email},
                    ).toString(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
