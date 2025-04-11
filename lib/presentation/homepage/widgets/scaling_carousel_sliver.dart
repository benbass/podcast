import 'package:flutter/material.dart';

class ScalingCarouselSliver extends StatefulWidget {
  final List<Widget> items;

  const ScalingCarouselSliver({super.key, required this.items});

  @override
  State<ScalingCarouselSliver> createState() => _ScalingCarouselSliverState();
}

class _ScalingCarouselSliverState extends State<ScalingCarouselSliver> {
  late PageController _pageController;
  final double _viewportFraction = 0.5;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      initialPage: 0, //widget.items.length - 1,
      viewportFraction: _viewportFraction,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200.0,
      child: PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.horizontal,
        itemCount: widget.items.length,
        itemBuilder: (context, index) {
          return AnimatedBuilder(
            animation: _pageController,
            builder: (context, child) {
              double value = 1.0;
              if (_pageController.position.haveDimensions) {
                value = (_pageController.page! - index).abs();
                value =
                    (1 - (value * 0.6)).clamp(0.0, 1.0); // Scale factor
              }
              return Center(
                child: SizedBox(
                  height:
                      Curves.easeOut.transform(value) * 200, // Animated height
                  width: Curves.easeOut.transform(value) *
                      200, // Animated width
                  child: Opacity(
                    opacity:
                        Curves.easeOut.transform(value), // Animated opacity
                    child: child,
                  ),
                ),
              );
            },
            child: widget.items[index],
          );
        },
      ),
    );
  }
}
