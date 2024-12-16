import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';

int androidVersion = 0;

getAndroidVersion() async {
  if (Platform.isAndroid) {
    var androidInfo = await DeviceInfoPlugin().androidInfo;
    var release = androidInfo.version.release;
    androidVersion = int.parse(release);
  }
}