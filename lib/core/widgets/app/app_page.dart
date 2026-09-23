import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../adaptive.dart';

/// A scrolling screen inside the app, in each platform's own grammar:
/// - iOS: large collapsing title on top-level screens, inline title on detail
///   screens, Cupertino pull-to-refresh, edge-swipe back.
/// - Android: Material 3 large or small top app bar and a refresh indicator.
class AppPage extends StatelessWidget {
  const AppPage({
    super.key,
    required this.title,
    required this.slivers,
    this.topLevel = false,
    this.onRefresh,
    this.actions = const [],
    this.grouped = false,
  });

  final String title;
  final List<Widget> slivers;

  /// Top-level tab screens get a large title; pushed screens an inline one.
  final bool topLevel;
  final Future<void> Function()? onRefresh;
  final List<Widget> actions;

  /// Screens made of grouped list sections: on iOS the page takes the
  /// grouped background so sections and page read as one surface.
  final bool grouped;

  @override
  Widget build(BuildContext context) {
    final bottomGap = SliverToBoxAdapter(
      child: SizedBox(height: MediaQuery.paddingOf(context).bottom + 24),
    );

    if (useCupertino(context)) {
      final surface = grouped
          ? CupertinoColors.systemGroupedBackground.resolveFrom(context)
          : Theme.of(context).colorScheme.surface;
      final trailing = actions.isEmpty
          ? null
          : Row(mainAxisSize: MainAxisSize.min, children: actions);
      final scroll = CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        slivers: [
          if (topLevel)
            CupertinoSliverNavigationBar(
              largeTitle: Text(title),
              backgroundColor: surface.withValues(alpha: 0.92),
              border: null,
              trailing: trailing,
            ),
          if (onRefresh != null)
            CupertinoSliverRefreshControl(onRefresh: onRefresh),
          ...slivers,
          bottomGap,
        ],
      );
      return Scaffold(
        backgroundColor: surface,
        // Detail screens: inline title with the system back chevron.
        appBar: topLevel
            ? null
            : CupertinoNavigationBar(
                middle: Text(title),
                trailing: trailing,
                backgroundColor: surface.withValues(alpha: 0.92),
              ),
        body: scroll,
      );
    }

    final scroll = CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        if (topLevel)
          SliverAppBar.large(title: Text(title), actions: actions)
        else
          SliverAppBar(pinned: true, title: Text(title), actions: actions),
        ...slivers,
        bottomGap,
      ],
    );
    return Scaffold(
      body: onRefresh == null
          ? scroll
          : RefreshIndicator(
              onRefresh: onRefresh!,
              edgeOffset: 152,
              child: scroll,
            ),
    );
  }
}
