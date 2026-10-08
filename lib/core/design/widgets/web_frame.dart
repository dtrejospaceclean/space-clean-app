import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../tokens.dart';

/// In a browser wider than a tablet, keeps the app in a centered column
/// [maxWidth] wide over the ground color, so screens laid out for phones
/// and tablets don't stretch across a desktop window. Everything below
/// (dialogs and sheets included) sees the column's width as the screen's.
/// On phones and tablets, and in narrow windows, it changes nothing.
class WebFrame extends StatelessWidget {
  const WebFrame({super.key, required this.child, this.enabled = kIsWeb});

  final Widget child;

  /// Off outside the browser; tests turn it on.
  final bool enabled;

  /// The widest tablet the screenshot sheets check (`tool/screenshots`).
  static const maxWidth = 1024.0;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    if (!enabled || media.size.width <= maxWidth) return child;
    return ColoredBox(
      color: context.colors.ground,
      child: Center(
        child: SizedBox(
          width: maxWidth,
          child: MediaQuery(
            data: media.copyWith(size: Size(maxWidth, media.size.height)),
            child: child,
          ),
        ),
      ),
    );
  }
}
