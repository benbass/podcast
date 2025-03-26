import 'package:flutter/material.dart';

import '../../injection.dart';
import '../core/connectivity_manager.dart';

void listenToConnectivity(BuildContext context){
  getIt<ConnectivityManager>().connectionType.listen((type) {
    if (type == ConnectionType.none) {
      if (context.mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text('No Internet Connection'),
            content: const Text('Please check your internet connection.'),
            actions: [
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          ),
        );
      }
    }
    if (type == ConnectionType.mobile) {
      if (context.mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text('Mobile Data Detected'),
            content: const Text(
                'You are currently using mobile data. Downloading may incur costs.'),
            actions: [
              TextButton(
                child: const Text('Ok'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          ),
        );
      }
    }
  });
}