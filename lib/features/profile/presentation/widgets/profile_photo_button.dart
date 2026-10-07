import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design/design.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/l10n/failure_messages.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../../core/widgets/adaptive.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../di/profile_providers.dart';
import '../photo_picker.dart';

/// The signed-in user's avatar on Me, with a camera badge: tapping it takes
/// or chooses a new photo, or removes the current one.
class ProfilePhotoButton extends ConsumerStatefulWidget {
  const ProfilePhotoButton({super.key, required this.user, this.size = 64});

  final User user;
  final double size;

  @override
  ConsumerState<ProfilePhotoButton> createState() => _ProfilePhotoButtonState();
}

class _ProfilePhotoButtonState extends ConsumerState<ProfilePhotoButton> {
  static const _camera = 'camera';
  static const _library = 'library';
  static const _remove = 'remove';

  bool _busy = false;

  Future<void> _change() async {
    final l10n = AppLocalizations.of(context);
    final choice = await showAppChoice(
      context,
      title: l10n.changePhoto,
      allowClear: false,
      options: {
        _camera: l10n.takePhoto,
        _library: l10n.chooseFromLibrary,
        if (widget.user.photoUrl != null) _remove: l10n.removePhoto,
      },
      destructive: const {_remove},
    );
    if (choice == null || !mounted) return;

    String? problem;
    try {
      final User saved;
      if (choice == _remove) {
        setState(() => _busy = true);
        saved = await ref.read(removeMyPhotoProvider)(const NoParams());
      } else {
        final photo = await ref
            .read(photoPickerProvider)
            .pick(choice == _camera ? PhotoSource.camera : PhotoSource.library);
        if (photo == null || !mounted) return;
        setState(() => _busy = true);
        saved = await ref.read(setMyPhotoProvider)(photo);
      }
      ref.read(authControllerProvider.notifier).replaceUser(saved);
    } on Failure catch (f) {
      problem = l10n.failureMessage(f);
    } on PhotoAccessDenied {
      problem = l10n.photoAccessDenied;
    } on Exception {
      problem = l10n.photoPickFailed;
    } finally {
      if (mounted) setState(() => _busy = false);
    }
    if (problem != null) await _tell(problem);
  }

  Future<void> _tell(String message) async {
    if (!mounted) return;
    final l10n = AppLocalizations.of(context);
    await showAdaptiveDialog<void>(
      context: context,
      builder: (context) => AlertDialog.adaptive(
        content: Text(message),
        actions: [
          adaptiveAction(
            context,
            label: l10n.doneButton,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final size = widget.size;
    return Tooltip(
      message: l10n.changePhoto,
      child: Semantics(
        button: true,
        label: l10n.changePhoto,
        excludeSemantics: true,
        child: SizedBox.square(
          dimension: size,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Material(
                type: MaterialType.transparency,
                shape: const CircleBorder(),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: _busy ? null : _change,
                  child: InitialsAvatar(
                    name: widget.user.name,
                    photoUrl: widget.user.photoUrl,
                    size: size,
                    background: c.accent,
                    foreground: c.onAccent,
                  ),
                ),
              ),
              if (_busy)
                Positioned.fill(
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: c.surface.withValues(alpha: 0.7),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: SizedBox.square(
                          dimension: size * 0.36,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: c.accent,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              // The camera badge says the avatar can be changed. A ring in
              // the card's tone keeps it apart from the photo.
              PositionedDirectional(
                end: -2,
                bottom: -2,
                child: IgnorePointer(
                  child: Container(
                    width: 26,
                    height: 26,
                    decoration: ShapeDecoration(
                      color: c.primary,
                      shape: CircleBorder(
                        side: BorderSide(color: c.surface, width: 2),
                      ),
                    ),
                    child: Icon(
                      Icons.photo_camera_rounded,
                      size: 14,
                      color: c.onPrimary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
