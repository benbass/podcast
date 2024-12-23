import 'dart:io';

import 'package:flutter/material.dart';

import '../../../helpers/core/get_android_version.dart';

class AndroidBottomPadding extends StatelessWidget {
  const AndroidBottomPadding({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Platform.isAndroid && androidVersion > 14
        ? Container(
      color: Theme.of(context).colorScheme.primaryContainer,
      height: MediaQuery.of(context).padding.bottom,
    )
        : const SizedBox.shrink();
  }
}