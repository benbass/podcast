import 'package:flutter/material.dart';
import 'package:podcast/presentation/audioplayer_overlays/widgets/mini_player_widget.dart';

OverlayEntry? overlayEntry;
OverlayState? overlayState;

// Common positioning
OverlayEntry _createOverlayEntry(BuildContext context, {required Widget child}) {
  return OverlayEntry(
    builder: (context) => Positioned(
      bottom: MediaQuery.of(context).padding.bottom,
      left: 0,
      right: 0,
      child: child,
    ),
  );
}

void showOverlayPlayerMin(BuildContext context) async {
  overlayState = Overlay.of(context);
  overlayEntry = _createOverlayEntry(
      context,
      child: const MiniPlayerWidget());

  overlayState!.insert(overlayEntry!);
}

void showOverlayError(BuildContext context, String message) async {
  overlayState = Overlay.of(context);
  overlayEntry = _createOverlayEntry(
      context,
      child:  Material(
        color: Colors.transparent,
        child: Container(
          height: 40,
          color: Colors.black,
          padding: const EdgeInsets.all(8),
          child: Center(
            child: Text(
              message,
              style: const TextStyle(
                  color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ));

  overlayState!.insert(overlayEntry!);
  Future.delayed(const Duration(seconds: 5), () {
    overlayEntry?.remove();
  });
}

void removeOverlay() async {
  overlayEntry?.remove();
  overlayEntry = null;
}
