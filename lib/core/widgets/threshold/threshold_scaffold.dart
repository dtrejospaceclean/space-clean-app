import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../theme/threshold_palette.dart';

/// Full-screen ground for everything before sign-in: white in light mode,
/// ember in dark (see `ThresholdPalette`).
///
/// Layout, top to bottom: a bar (platform back button, [trailing]), the
/// [header], flexible space, then [body] anchored toward the thumb zone. It
/// scrolls when the keyboard or large text leaves too little room.
///
/// On tablets the thumb-zone rule doesn't apply: the column is capped in width
/// and the header and body sit together as one centered group.
class ThresholdScaffold extends StatelessWidget {
  const ThresholdScaffold({
    super.key,
    required this.body,
    this.header,
    this.trailing,
    this.centerHeader = false,
  });

  final Widget body;
  final Widget? header;
  final Widget? trailing;

  /// Centers the header in the free space above the body (brand screens);
  /// otherwise it sits right under the bar (task screens).
  final bool centerHeader;

  /// Widest the form gets, so fields and the button don't stretch on tablets.
  static const maxContentWidth = 480.0;

  @override
  Widget build(BuildContext context) {
    final palette = ThresholdPalette.of(context);
    final canPop = GoRouter.maybeOf(context)?.canPop() ?? false;
    final tablet = MediaQuery.sizeOf(context).shortestSide >= 600;
    // Phones push the body toward the thumb; tablets keep a fixed gap.
    final Widget gap = tablet ? const SizedBox(height: 48) : const Spacer();
    final content = [
      if (centerHeader) ...[
        if (!tablet) const Spacer(),
        ?header,
        gap,
        // Keeps the brand clear of the form on short screens.
        const SizedBox(height: 32),
      ] else ...[
        if (header case final header?) ...[const SizedBox(height: 8), header],
        gap,
        const SizedBox(height: 32),
      ],
      body,
    ];

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: palette.systemOverlay.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: palette.ground,
      ),
      child: Scaffold(
        backgroundColor: palette.ground,
        body: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverFillRemaining(
                hasScrollBody: false,
                // Phone-width column, centered on tablets.
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: maxContentWidth,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // The bar stays pinned to the top on every device.
                          ConstrainedBox(
                            // Grows with large text instead of clipping.
                            constraints: const BoxConstraints(minHeight: 64),
                            child: Row(
                              children: [
                                if (canPop)
                                  Transform.translate(
                                    offset: const Offset(-12, 0),
                                    child: BackButton(color: palette.onGround),
                                  ),
                                const Spacer(),
                                ?trailing,
                              ],
                            ),
                          ),
                          if (tablet)
                            Expanded(
                              child: Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: content,
                                ),
                              ),
                            )
                          else
                            ...content,
                        ],
                      ),
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

/// Screen title and optional intro for task screens (reset steps).
class ThresholdHeading extends StatelessWidget {
  const ThresholdHeading({super.key, required this.title, this.intro});

  final String title;
  final String? intro;

  @override
  Widget build(BuildContext context) {
    final palette = ThresholdPalette.of(context);
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          header: true,
          child: Text(
            title,
            style: textTheme.headlineMedium?.copyWith(
              color: palette.onGround,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
          ),
        ),
        if (intro case final intro?) ...[
          const SizedBox(height: 12),
          Text(
            intro,
            style: textTheme.bodyLarge?.copyWith(
              color: palette.onGroundMuted,
              fontSize: 17,
              height: 1.45,
            ),
          ),
        ],
      ],
    );
  }
}
