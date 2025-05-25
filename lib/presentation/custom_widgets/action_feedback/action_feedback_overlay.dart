import 'package:flutter/material.dart';

class ActionFeedbackOverlay extends StatefulWidget {
  final IconData icon;
  final VoidCallback onDispose;
  final Offset? tapDownPosition;

  const ActionFeedbackOverlay({
    super.key,
    required this.icon,
    required this.onDispose,
    this.tapDownPosition,
  });

  @override
  State<ActionFeedbackOverlay> createState() => ActionFeedbackOverlayState();
}

class ActionFeedbackOverlayState extends State<ActionFeedbackOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<double> _sizeAnimation;
  late Animation<Offset> _positionAnimation;

  // Helper variable to ensure that the position animation is only initialized once
  bool _isPositionAnimationInitialized = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 0.7).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutBack),
    );

    _sizeAnimation = Tween<double>(begin: 50.0, end: 190.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutBack),
    );

    _controller.forward().then((_) {
      _controller.reverse().then((_) {
        widget.onDispose();
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _initializePositionAnimation(BuildContext context) {
    if (_isPositionAnimationInitialized || !mounted) return;

    final Size screenSize = MediaQuery.of(context).size;

    final Offset initialIconCenterPosition = widget.tapDownPosition ??
        Offset(screenSize.width / 2, screenSize.height / 2);

    final Offset targetIconCenterPosition =
        Offset(screenSize.width / 2, screenSize.height / 2);

    // The Tween animates the center of the icon.
    _positionAnimation = Tween<Offset>(
      begin: initialIconCenterPosition,
      end: targetIconCenterPosition,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOutSine,
      ),
    );

    _isPositionAnimationInitialized = true;
  }

  @override
  Widget build(BuildContext context) {
    // Initialize the position animation here, if it hasn't been initialized yet.
    // This makes sure that `MediaQuery.of(context)` is available.
    if (!_isPositionAnimationInitialized) {
      _initializePositionAnimation(context);
    }

    // When the position animation hasn't been initialized yet (e.g. because the first build hasn't completed yet or
    // the context is not fully available), show an empty container (or a fallback).
    if (!_isPositionAnimationInitialized) {
      return const SizedBox.shrink();
    }
    return AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          // Calculate the current left and top position based on the animated center position and the animated size.
          final double currentIconSize = _sizeAnimation.value;
          final Offset currentIconCenter = _positionAnimation.value;

          final double left = currentIconCenter.dx - (currentIconSize / 2);
          final double top = currentIconCenter.dy - (currentIconSize / 2);
          return Positioned(
            left: left,
            top: top,
            child: FadeTransition(
              opacity: _opacityAnimation,
              child: Icon(
                widget.icon,
                color: Theme.of(context).colorScheme.secondary,
                size: currentIconSize,
              ),
            ),
          );
        });
  }
}
