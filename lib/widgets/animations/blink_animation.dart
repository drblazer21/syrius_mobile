import 'package:flutter/material.dart';

class BlinkAnimationWidget extends StatefulWidget {
  final Widget child;

  const BlinkAnimationWidget({
    required this.child,
    super.key,
  });
  @override
  BlinkAnimationWidgetState createState() => BlinkAnimationWidgetState();
}

class BlinkAnimationWidgetState extends State<BlinkAnimationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animationController,
      child: widget.child,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void start() {
    _animationController.forward();
    _animationController.repeat(reverse: true);
  }

  void stop() {
    _animationController.stop();
    _animationController.forward();
  }
}
