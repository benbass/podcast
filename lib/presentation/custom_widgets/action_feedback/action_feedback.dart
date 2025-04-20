import 'package:flutter/material.dart';

import 'action_feedback_overlay.dart';

class ActionFeedback extends StatelessWidget {
  const ActionFeedback({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox();
  }

  static void show(BuildContext context, {required IconData icon}) {
    OverlayEntry? overlayEntry;
    overlayEntry = OverlayEntry(
      builder: (context) => ActionFeedbackOverlay(
        icon: icon,
        onDispose: () => overlayEntry?.remove(),
      ),
    );
    Overlay.of(context).insert(overlayEntry);
  }
}