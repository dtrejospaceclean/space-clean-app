import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../widgets/adaptive.dart';
import '../tokens.dart';
import 'circle_button.dart';
import 'space_page.dart';

/// A row of [slots] square photo slots: the [images], then an "Add photo"
/// tile while [onAdd] is set, then empty room. Tapping a photo calls
/// [onOpen]; with [onRemove] each photo also gets an × at its corner.
class PhotoStrip extends StatelessWidget {
  const PhotoStrip({
    super.key,
    required this.images,
    required this.slots,
    required this.onOpen,
    this.onAdd,
    this.adding = false,
    this.onRemove,
  });

  final List<ImageProvider> images;
  final int slots;
  final ValueChanged<int> onOpen;

  /// Null hides the add tile.
  final VoidCallback? onAdd;

  /// A spinner in the add tile while a photo uploads.
  final bool adding;

  final ValueChanged<int>? onRemove;

  @override
  Widget build(BuildContext context) {
    final showAdd = (onAdd != null || adding) && images.length < slots;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < slots; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          Expanded(
            child: AspectRatio(
              aspectRatio: 1,
              child: i < images.length
                  ? _Thumb(
                      image: images[i],
                      label: AppLocalizations.of(context)
                          .photoOf(i + 1, images.length),
                      onTap: () => onOpen(i),
                      onRemove: switch (onRemove) {
                        final remove? => () => remove(i),
                        null => null,
                      },
                    )
                  : i == images.length && showAdd
                  ? _AddTile(onTap: adding ? null : onAdd, busy: adding)
                  : const SizedBox.shrink(),
            ),
          ),
        ],
      ],
    );
  }
}

/// A photo filling its box, or a quiet placeholder while it loads or if it
/// can't.
class PhotoImage extends StatelessWidget {
  const PhotoImage({super.key, required this.image, this.fit = BoxFit.cover});

  final ImageProvider image;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    Widget placeholder({bool broken = false}) => ColoredBox(
      color: c.sunken,
      child: Center(
        child: broken
            ? Icon(
                Icons.broken_image_outlined,
                color: c.inkFaint,
                semanticLabel: AppLocalizations.of(context).photoLoadFailed,
              )
            : null,
      ),
    );
    return Image(
      image: image,
      fit: fit,
      width: double.infinity,
      height: double.infinity,
      gaplessPlayback: true,
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) =>
          wasSynchronouslyLoaded || frame != null ? child : placeholder(),
      errorBuilder: (context, error, stack) => placeholder(broken: true),
    );
  }
}

class _Thumb extends StatelessWidget {
  const _Thumb({
    required this.image,
    required this.label,
    required this.onTap,
    this.onRemove,
  });

  final ImageProvider image;
  final String label;
  final VoidCallback onTap;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l10n = AppLocalizations.of(context);
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(
          child: Semantics(
            container: true,
            button: true,
            image: true,
            label: label,
            excludeSemantics: true,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(SpaceRadius.inner),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  PhotoImage(image: image),
                  Material(
                    type: MaterialType.transparency,
                    child: InkWell(onTap: onTap),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (onRemove case final onRemove?)
          // A 24 dp badge inside a 40 dp target, over the corner.
          PositionedDirectional(
            top: -8,
            end: -8,
            child: Tooltip(
              message: l10n.removePhoto,
              child: Semantics(
                container: true,
                button: true,
                label: '${l10n.removePhoto}, $label',
                excludeSemantics: true,
                child: InkResponse(
                  onTap: onRemove,
                  radius: 20,
                  child: SizedBox.square(
                    dimension: 40,
                    child: Center(
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: ShapeDecoration(
                          color: c.ink,
                          shape: CircleBorder(
                            side: BorderSide(color: c.surface, width: 2),
                          ),
                        ),
                        child: Icon(
                          Icons.close_rounded,
                          size: 14,
                          color: c.surface,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _AddTile extends StatelessWidget {
  const _AddTile({required this.onTap, required this.busy});

  final VoidCallback? onTap;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final theme = Theme.of(context);
    final label = AppLocalizations.of(context).addPhoto;
    return Semantics(
      container: true,
      button: true,
      enabled: onTap != null,
      label: label,
      excludeSemantics: true,
      child: Material(
        color: c.sunken,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SpaceRadius.inner),
          side: BorderSide(color: c.line),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Center(
              child: busy
                  ? SizedBox.square(
                      dimension: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: c.primary,
                      ),
                    )
                  // Scaled down rather than clipped at large text.
                  : FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.add_a_photo_outlined,
                            color: c.inkMuted,
                            size: 26,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            label,
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: c.inkMuted,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Opens [images] full screen at [initial], above the dock: swipe between
/// them, pinch to zoom. With [onRemove] the header has a trash button: it
/// asks first ([removeTitle], [removeBody]), then [onRemove] says whether
/// the photo went, and the viewer then closes.
Future<void> showPhotoViewer(
  BuildContext context, {
  required List<ImageProvider> images,
  required int initial,
  Future<bool> Function(int index)? onRemove,
  String? removeTitle,
  String? removeBody,
}) => Navigator.of(context, rootNavigator: true).push(
  MaterialPageRoute<void>(
    fullscreenDialog: true,
    builder: (_) => _PhotoViewer(
      images: images,
      initial: initial,
      onRemove: onRemove,
      removeTitle: removeTitle,
      removeBody: removeBody,
    ),
  ),
);

class _PhotoViewer extends StatefulWidget {
  const _PhotoViewer({
    required this.images,
    required this.initial,
    this.onRemove,
    this.removeTitle,
    this.removeBody,
  });

  final List<ImageProvider> images;
  final int initial;
  final Future<bool> Function(int index)? onRemove;
  final String? removeTitle;
  final String? removeBody;

  @override
  State<_PhotoViewer> createState() => _PhotoViewerState();
}

class _PhotoViewerState extends State<_PhotoViewer> {
  late final _pages = PageController(initialPage: widget.initial);
  late int _index = widget.initial;
  bool _removing = false;

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  Future<void> _remove() async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showAdaptiveDialog<bool>(
      context: context,
      builder: (context) => AlertDialog.adaptive(
        title: Text(widget.removeTitle ?? l10n.removePhoto),
        content: switch (widget.removeBody) {
          final body? => Text(body),
          null => null,
        },
        actions: [
          adaptiveAction(
            context,
            label: l10n.keepPhoto,
            onPressed: () => Navigator.of(context).pop(false),
          ),
          adaptiveAction(
            context,
            label: l10n.removePhoto,
            destructive: true,
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _removing = true);
    final removed = await widget.onRemove!(_index);
    if (!mounted) return;
    if (removed) {
      Navigator.of(context).pop();
    } else {
      setState(() => _removing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final count = widget.images.length;
    return SpacePage(
      title: count > 1 ? l10n.photoOf(_index + 1, count) : l10n.photoTitle,
      showBack: true,
      actions: [
        if (widget.onRemove != null)
          CircleButton.light(
            icon: Icons.delete_outline_rounded,
            tooltip: l10n.removePhoto,
            busy: _removing,
            onPressed: _removing ? null : _remove,
          ),
      ],
      slivers: [
        SliverFillRemaining(
          hasScrollBody: true,
          child: Padding(
            padding: const EdgeInsets.only(top: 12),
            child: PageView.builder(
              controller: _pages,
              itemCount: count,
              onPageChanged: (i) => setState(() => _index = i),
              itemBuilder: (context, i) => InteractiveViewer(
                maxScale: 4,
                child: Semantics(
                  image: true,
                  label: l10n.photoOf(i + 1, count),
                  child: PhotoImage(
                    image: widget.images[i],
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
