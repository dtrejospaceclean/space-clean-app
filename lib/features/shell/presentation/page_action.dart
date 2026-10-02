import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Something a page adds in its own state (a proposal's line item), shown
/// as the "+" beside the tab dock while that page is on top. Route-based
/// "+" options open other pages; this one acts inside the page.
class PageAction {
  const PageAction({
    required this.location,
    required this.label,
    required this.onPressed,
    required this.owner,
    this.text,
  });

  /// The page's path; the action shows only while it's the page on top.
  final String location;

  /// Tooltip and screen-reader label ("Add line item").
  final String label;
  final VoidCallback onPressed;

  /// Drawn beside the "+" ("Line item"), so it says what it adds.
  final String? text;

  /// Who set it, so a page that's going away only clears its own.
  final Object owner;
}

final pageActionProvider = NotifierProvider<PageActionController, PageAction?>(
  PageActionController.new,
);

class PageActionController extends Notifier<PageAction?> {
  @override
  PageAction? build() => null;

  void set(PageAction action) => state = action;

  void clear(Object owner) {
    if (state?.owner == owner) state = null;
  }
}

/// Gives a [ConsumerStatefulWidget]'s page a "+" action beside the dock:
/// call [registerPageAction] once it's built, and the mixin clears it when
/// the page goes away.
mixin PageActionHost<T extends ConsumerStatefulWidget> on ConsumerState<T> {
  PageActionController? _actions;

  /// Sets the action for [location] after this frame, since providers can't
  /// change while the tree builds.
  void registerPageAction({
    required String location,
    required String label,
    required VoidCallback onPressed,
    String? text,
  }) {
    _actions = ref.read(pageActionProvider.notifier);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _actions!.set(
        PageAction(
          location: location,
          label: label,
          onPressed: onPressed,
          text: text,
          owner: this,
        ),
      );
    });
  }

  @override
  void dispose() {
    // Cleared after the tree settles, for the same reason.
    if (_actions case final actions?) {
      Future.microtask(() => actions.clear(this));
    }
    super.dispose();
  }
}
