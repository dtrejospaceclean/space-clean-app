import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design/design.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/l10n/failure_messages.dart';
import '../../../../l10n/app_localizations.dart';
import '../../di/clients_providers.dart';
import '../../domain/usecases/manage_clients.dart';
import '../controllers/clients_providers.dart';
import 'accounts_screen.dart';

/// Deletes an account with all of its history (owners only). Offered when a
/// plain delete is refused because the account has history; the legal name
/// must be typed first.
class PurgeAccountScreen extends ConsumerStatefulWidget {
  const PurgeAccountScreen({super.key, required this.clientId});

  static const route = 'purge';

  final String clientId;

  @override
  ConsumerState<PurgeAccountScreen> createState() => _PurgeAccountScreenState();
}

class _PurgeAccountScreenState extends ConsumerState<PurgeAccountScreen> {
  final _confirm = TextEditingController();
  bool _purging = false;
  Failure? _failure;

  @override
  void dispose() {
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _purge() async {
    setState(() {
      _purging = true;
      _failure = null;
    });
    try {
      await ref.read(purgeClientProvider)(widget.clientId);
      ref.invalidate(myClientsProvider);
      if (mounted) context.go(AccountsScreen.path);
    } on Failure catch (f) {
      HapticFeedback.mediumImpact();
      if (mounted) setState(() => _failure = f);
    } finally {
      if (mounted) setState(() => _purging = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final client = ref.watch(clientDetailProvider(widget.clientId));
    final failure = _failure;

    return SpacePage(
      title: l10n.purgeAccountTitle,
      slivers: [
        AsyncSlivers(
          value: client,
          skeleton: SkeletonLayout.form,
          onRetry: () =>
              ref.refresh(clientDetailProvider(widget.clientId).future),
          builder: (c) => SliverMainAxisGroup(
            slivers: [
              PageBox(
                top: 4,
                child: Notice(message: l10n.purgeAccountWarning(c.displayName)),
              ),
              if (failure != null)
                PageBox(
                  top: 12,
                  child: Notice(message: l10n.failureMessage(failure)),
                ),
              PageBox(
                top: 12,
                child: SpaceCard(
                  child: SpaceTextField(
                    label: l10n.purgeAccountConfirmLabel,
                    controller: _confirm,
                    enabled: !_purging,
                    hint: c.legalName,
                    textInputAction: TextInputAction.done,
                    onChanged: (_) => setState(() {}),
                  ),
                ),
              ),
              PageBox(
                top: 24,
                child: SecondaryButton(
                  label: l10n.purgeAccountButton,
                  icon: Icons.delete_forever_outlined,
                  destructive: true,
                  onPressed:
                      !_purging &&
                          AccountAdminPolicy.confirmsPurge(
                            _confirm.text,
                            c.legalName,
                          )
                      ? _purge
                      : null,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
