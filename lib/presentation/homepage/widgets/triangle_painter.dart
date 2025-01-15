import 'package:flutter/material.dart';

class TrianglePainter extends CustomPainter {
  final String text;

  TrianglePainter({required this.text});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.red;

    final path = Path()
      ..moveTo(size.width, 0) // Top right corner
      ..lineTo(size.width, size.height) // Bottom right corner
      ..lineTo(0, 0) // Top left corner
      ..close();

    canvas.drawPath(path, paint);

    // Text zeichnen
    final textSpan = TextSpan(
      text: text,
      style: const TextStyle(fontSize: 13,),
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(minWidth: 0, maxWidth: size.width);

    // Position des Textes berechnen
    final textX = size.width / 2;
    final textY = size.height / 2 - textPainter.height;

    // Text zeichnen
    textPainter.paint(canvas, Offset(textX, textY));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
