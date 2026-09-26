import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

/// A cross-fade for top-level swaps (splash, sign-in, the signed-in app),
/// which replace the stack rather than push onto it. Pushed screens keep the
/// native transition and back gesture. Instant under reduced motion.
CustomTransitionPage<void> fadePage(GoRouterState state, Widget child) =>
    CustomTransitionPage<void>(
      key: state.pageKey,
      child: child,
      transitionDuration: const Duration(milliseconds: 300),
      reverseTransitionDuration: const Duration(milliseconds: 300),
      transitionsBuilder: (context, animation, _, child) =>
          MediaQuery.disableAnimationsOf(context)
          ? child
          : FadeTransition(
              opacity: CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              ),
              child: child,
            ),
    );
