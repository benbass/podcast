import 'package:flutter/material.dart';

class MyImageProvider {
  final String url;

  MyImageProvider({required this.url});

  ImageProvider get imageProvider {
    try {
      return url.isNotEmpty
          ? NetworkImage(url)
          : const AssetImage("assets/placeholder.png");
    } catch (e) {
      return const AssetImage("assets/placeholder.png");
    }
  }
}
