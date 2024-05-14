import 'package:flutter/material.dart';

class ShakeWidget extends StatefulWidget {
  const ShakeWidget({
    super.key,
    required this.child,
    this.controller,
    this.duration = const Duration(seconds: 1),
    this.deltaX = 20,
    this.curve = Curves.bounceOut,
  });
  final Widget child;
  final Duration duration;
  final double deltaX;
  final Curve curve;
  final Function(AnimationController)? controller;

  @override
  State<ShakeWidget> createState() => _ShakeWidgetState();
}

class _ShakeWidgetState extends State<ShakeWidget>
    with SingleTickerProviderStateMixin<ShakeWidget> {
  late AnimationController _animationController;
  late Animation<double> offsetAnimation;

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(duration: widget.duration, vsync: this);
    offsetAnimation = Tween<double>(begin: 0.0, end: 1.0)
        .chain(CurveTween(curve: widget.curve))
        .animate(_animationController);
    if (widget.controller is Function) {
      widget.controller!(_animationController);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: offsetAnimation,
      builder: (BuildContext context, Widget? child) {
        return Transform.translate(
          offset: Offset(widget.deltaX * shake(offsetAnimation.value), 0),
          child: child,
        );
      },
      child: widget.child,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  double shake(double animation) =>
      2 * (0.5 - (0.5 - widget.curve.transform(animation)).abs());
}
