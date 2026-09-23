import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';

/// Placeholder landing screen until the real dashboard exists.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static const path = '/';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final auth = ref.watch(authControllerProvider).value;
    if (auth is! Authenticated) return const SizedBox.shrink();
    final user = auth.user;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          IconButton(
            tooltip: l10n.signOutButton,
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authControllerProvider.notifier).logout(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.homeWelcome(user.name),
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(user.email),
            const SizedBox(height: 8),
            Text(l10n.homeRoles(user.roles.map((r) => r.name).join(', '))),
          ],
        ),
      ),
    );
  }
}
