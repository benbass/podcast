import 'package:flutter/material.dart';

import '../../injection.dart';
import '../player/audiohandler.dart';

class MyAppLifecycleObserver extends WidgetsBindingObserver {

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.detached) {
      // App is being closed
      getItI<MyAudioHandler>().dispose();
    }
  }
}