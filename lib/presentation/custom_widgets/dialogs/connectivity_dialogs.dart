import 'package:flutter/material.dart';
import 'package:podcast/presentation/custom_widgets/effects/backdropfilter.dart';

import '../../../injection.dart';
import '../../../helpers/core/connectivity_manager.dart';

class ConnectivityDialog {
  static void showConnectivityDialogs(BuildContext context) {
    getIt<ConnectivityManager>().connectionType.listen((type) {
      if (type == ConnectionType.none) {
        if (context.mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => Stack(
              children: [
                const BackdropFilterWidget(sigma: 4.0),
                AlertDialog(
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
            builder: (context) => Stack(
              children: [
                const BackdropFilterWidget(sigma: 4.0),
                AlertDialog(
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
              ],
            ),
          );
        }
      }
    });
  }
}
