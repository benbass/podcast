import 'package:flutter/material.dart';

class ActionFeedbackOverlay extends StatefulWidget {
  final IconData icon;
  final VoidCallback onDispose;

  const ActionFeedbackOverlay({
    super.key,
    required this.icon,
    required this.onDispose,
  });

  @override
  State<ActionFeedbackOverlay> createState() => ActionFeedbackOverlayState();
}

class ActionFeedbackOverlayState extends State<ActionFeedbackOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<double> _sizeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 0.7).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _sizeAnimation = Tween<double>(begin: 50.0, end: 250.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _controller.forward().then((_) {
      Future.delayed(const Duration(milliseconds: 300), () {
        _controller.reverse().then((_) {
          widget.onDispose();
        });
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FadeTransition(
        opacity: _opacityAnimation,
        child: AnimatedBuilder(
          animation: _sizeAnimation,
          builder: (context, child) {
            return Icon(
              widget.icon,
              color: Theme.of(context).colorScheme.secondary,
              size: _sizeAnimation.value,
            );
          }
        ),
      ),
    );
  }
}
