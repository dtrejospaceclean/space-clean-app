import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../users/presentation/screens/user_form_screen.dart';

/// The signed-in user's own record, in the same form owners use for anyone
/// (the API only lets owners edit users, themselves included).
class EditProfileScreen extends ConsumerWidget {
  const EditProfileScreen({super.key});

  static const path = '/me/edit';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return switch (ref.watch(authControllerProvider).value) {
      Authenticated(:final user) => UserFormScreen(
        userId: user.id,
        title: AppLocalizations.of(context).editProfile,
      ),
      _ => const SizedBox.shrink(),
    };
  }
}
