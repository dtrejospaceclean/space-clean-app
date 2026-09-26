import 'package:flutter/widgets.dart';

/// Holds the tab stacks like an IndexedStack (each keeps its state), and fades
/// the newly selected tab in with a slight rise. Instant under reduced motion.
class FadeBranchContainer extends StatefulWidget {
  const FadeBranchContainer({
    super.key,
    required this.currentIndex,
    required this.children,
  });

  final int currentIndex;
  final List<Widget> children;

  static const duration = Duration(milliseconds: 260);

  @override
  State<FadeBranchContainer> createState() => _FadeBranchContainerState();
}

class _FadeBranchContainerState extends State<FadeBranchContainer>
    with TickerProviderStateMixin {
  late final List<AnimationController> _controllers = [
    for (var i = 0; i < widget.children.length; i++)
      AnimationController(
        vsync: this,
        duration: FadeBranchContainer.duration,
        value: i == widget.currentIndex ? 1 : 0,
      ),
  ];

  late final List<Animation<double>> _curves = [
    for (final c in _controllers)
      CurvedAnimation(parent: c, curve: Curves.easeOutCubic),
  ];

  @override
  void didUpdateWidget(FadeBranchContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    final previous = oldWidget.currentIndex;
    final current = widget.currentIndex;
    if (previous == current) return;
    _controllers[previous].value = 0;
    if (MediaQuery.disableAnimationsOf(context)) {
      _controllers[current].value = 1;
    } else {
      _controllers[current].forward(from: 0);
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        for (var i = 0; i < widget.children.length; i++)
          Offstage(
            offstage: i != widget.currentIndex,
            child: TickerMode(
              enabled: i == widget.currentIndex,
              child: FadeTransition(
                opacity: _curves[i],
                child: SlideTransition(
                  position: _curves[i].drive(
                    Tween(begin: const Offset(0, 0.015), end: Offset.zero),
                  ),
                  child: widget.children[i],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
