import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';

// We need the android version to determine how edge-to-edge must be handled
int androidVersion = 0;

getAndroidVersion() async {
  if (Platform.isAndroid) {
    var androidInfo = await DeviceInfoPlugin().androidInfo;
    var release = androidInfo.version.release;
    androidVersion = int.parse(release);
  }
}