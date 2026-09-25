import 'package:flutter/material.dart';

import '../../../../core/design/design.dart';

/// One step of the password reset: title, muted intro, and the form in a
/// white card.
class ResetStepPage extends StatelessWidget {
  const ResetStepPage({
    super.key,
    required this.title,
    required this.intro,
    required this.child,
  });

  final String title;
  final String intro;
  final Widget child;

  @override
  Widget build(BuildContext context) => SpacePage(
    title: title,
    slivers: [
      PageBox(
        top: 0,
        child: Text(
          intro,
          style: Theme.of(context).textTheme.bodyLarge
              ?.copyWith(color: context.colors.inkMuted),
        ),
      ),
      PageBox(top: 20, child: SpaceCard(child: child)),
    ],
  );
}
