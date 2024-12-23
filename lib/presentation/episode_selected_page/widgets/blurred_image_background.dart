import 'dart:ui';

import 'package:flutter/material.dart';

class BlurredImageBackground extends StatelessWidget {
  final ImageProvider image;
  final Widget child;

  const BlurredImageBackground({
    super.key,
    required this.image,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: image,
          fit: BoxFit.fitWidth,
        ),
      ),
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(4.0),
            decoration: const BoxDecoration(
              color: Colors.black38,
            ),
          ),
          ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}