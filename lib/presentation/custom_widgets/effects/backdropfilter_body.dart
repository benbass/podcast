import 'dart:ui';

import 'package:flutter/material.dart';

class BackdropFilterBody extends StatelessWidget {
  const BackdropFilterBody({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 25.0, sigmaY: 25.0),
      child: Container(
        color: Colors.black26,
      ),
    );
  }
}