import 'package:flutter/material.dart';
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

/// A [GoRoute] whose screen is pushed as a [MaterialPage], so it moves with
/// the theme's page transition (the slide from the right, see
/// `SlidePageTransitions`) and keeps the swipe back. Use it for every
/// screen with a `builder`: left to itself, go_router may pick a page with
/// no transition at all inside the shell's tab navigators.
class SlideRoute extends GoRoute {
  SlideRoute({
    required super.path,
    required GoRouterWidgetBuilder builder,
    super.routes,
  }) : super(
         pageBuilder: (context, state) => MaterialPage<void>(
           key: state.pageKey,
           name: state.name ?? state.path,
           restorationId: state.pageKey.value,
           child: Builder(builder: (context) => builder(context, state)),
         ),
       );
}
