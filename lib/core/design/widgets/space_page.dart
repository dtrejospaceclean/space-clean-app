import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../tokens.dart';
import 'circle_button.dart';

/// Every screen's frame: gray ground, a header with a big bold title and
/// round action buttons, then scrolling content.
///
/// Top-level screens put the title and buttons on one row. Pushed screens get
/// a white round back button with the title under it; the platform's back
/// gesture keeps working (go_router pages).
class SpacePage extends StatelessWidget {
  const SpacePage({
    super.key,
    this.title,
    required this.slivers,
    this.actions = const [],
    this.onRefresh,
    this.bottom,
    this.showBack,
  });

  /// Big title; omitted on screens whose hero headline says it all.
  final String? title;
  final List<Widget> slivers;

  /// Round buttons on the right of the header.
  final List<Widget> actions;
  final Future<void> Function()? onRefresh;

  /// Pinned at the bottom (e.g. a save button over the keyboard).
  final Widget? bottom;

  /// Defaults to whether the router can go back.
  final bool? showBack;

  @override
  Widget build(BuildContext context) {
    final canPop = showBack ?? (GoRouter.maybeOf(context)?.canPop() ?? false);

    final header = canPop
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleButton.light(
                    icon: Icons.arrow_back_rounded,
                    tooltip: MaterialLocalizations.of(context)
                        .backButtonTooltip,
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                  const Spacer(),
                  ..._spaced(actions),
                ],
              ),
              if (title != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16, bottom: 8),
                  child: _Title(title!),
                ),
            ],
          )
        : ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 56),
            child: Row(
              children: [
                Expanded(
                  child: title == null
                      ? const SizedBox.shrink()
                      : _Title(title!),
                ),
                ..._spaced(actions),
              ],
            ),
          );

    final scroll = CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverSafeArea(
          bottom: false,
          sliver: SliverPadding(
            padding: EdgeInsets.fromLTRB(
              pageSide(context),
              12,
              pageSide(context),
              0,
            ),
            sliver: SliverToBoxAdapter(child: header),
          ),
        ),
        ...slivers,
        SliverToBoxAdapter(
          child: SizedBox(height: MediaQuery.paddingOf(context).bottom + 24),
        ),
      ],
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      // Status bar icons contrast with the ground in either theme.
      value:
          (Theme.of(context).brightness == Brightness.dark
                  ? SystemUiOverlayStyle.light
                  : SystemUiOverlayStyle.dark)
              .copyWith(statusBarColor: Colors.transparent),
      child: Scaffold(
        backgroundColor: context.colors.ground,
        body: onRefresh == null
            ? scroll
            : RefreshIndicator.adaptive(
                onRefresh: onRefresh!,
                color: context.colors.primary,
                child: scroll,
              ),
        bottomNavigationBar: bottom,
      ),
    );
  }
}

/// Content never gets wider than this; on tablets it sits centered.
const maxContentWidth = 640.0;

/// Side margin: the page margin on phones, more on wide screens so content
/// stays [maxContentWidth] wide and centered.
double pageSide(BuildContext context) {
  final width = MediaQuery.sizeOf(context).width;
  final centered = (width - maxContentWidth) / 2;
  return centered > SpaceSpace.page ? centered : SpaceSpace.page;
}

List<Widget> _spaced(List<Widget> actions) => [
  for (final (i, action) in actions.indexed) ...[
    if (i > 0) const SizedBox(width: 10),
    action,
  ],
];

class _Title extends StatelessWidget {
  const _Title(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Semantics(
    header: true,
    child: Text(text, style: Theme.of(context).textTheme.headlineLarge),
  );
}

/// Page-width padding for a sliver.
class PageSliver extends StatelessWidget {
  const PageSliver({super.key, required this.sliver, this.top = 16});

  final Widget sliver;
  final double top;

  @override
  Widget build(BuildContext context) {
    final side = pageSide(context);
    return SliverPadding(
      padding: EdgeInsets.fromLTRB(side, top, side, 0),
      sliver: sliver,
    );
  }
}

/// A box widget as a padded page sliver.
class PageBox extends StatelessWidget {
  const PageBox({super.key, required this.child, this.top = 16});

  final Widget child;
  final double top;

  @override
  Widget build(BuildContext context) => PageSliver(
    top: top,
    sliver: SliverToBoxAdapter(child: child),
  );
}
