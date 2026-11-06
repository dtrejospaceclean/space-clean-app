import 'package:flutter/widgets.dart';

/// A conversation's messages over its composer. The composer keeps its own
/// height and the messages take what's left, down to nothing. If the
/// composer doesn't fit either (for a moment when the photo picker opens
/// while the keyboard is still closing: both take space), it scrolls
/// within the page instead of overflowing.
class ConversationLayout extends StatelessWidget {
  const ConversationLayout({
    super.key,
    required this.messages,
    required this.composer,
  });

  final Widget messages;
  final Widget composer;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) => Column(
      children: [
        Expanded(child: messages),
        ConstrainedBox(
          constraints: BoxConstraints(maxHeight: constraints.maxHeight),
          child: SingleChildScrollView(child: composer),
        ),
      ],
    ),
  );
}
