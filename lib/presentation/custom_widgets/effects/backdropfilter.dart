import 'dart:ui';

import 'package:flutter/material.dart';

class BackdropFilterWidget extends StatelessWidget {
  // sigma = 25 for body background
  // sigma = 4 for dialog background
  final double sigma;
  const BackdropFilterWidget({
    super.key, required this.sigma,
  });

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
      child: Container(
        color: Colors.black38,
      ),
    );
  }
}