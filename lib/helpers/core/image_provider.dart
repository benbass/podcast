import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:http/http.dart' as http;

class MyImageProvider {
  final String url;

  MyImageProvider({required this.url});

  Future<ImageProvider> get imageProvider async {
    if (url.isEmpty) {
      return const AssetImage("assets/placeholder.png");
    }

    try {
      if (url.startsWith('http')) {
        final response = await http.head(Uri.parse(url));
        if (response.statusCode == 404 || response.statusCode != 200) {
          return const AssetImage("assets/placeholder.png");
        }
          try {
            //check if it is a valid image
            final data = await NetworkAssetBundle(Uri.parse(url)).load(url);
            await decodeImageFromList(data.buffer.asUint8List());
            // url is a valid image url
            return NetworkImage(url);
          } catch (_) {
            return const AssetImage("assets/placeholder.png");
          }

      } else {
        // url is a file path when podcast is subscribed
        File(url);
        return FileImage(File(url));
      }
    } catch (_) {
      return const AssetImage("assets/placeholder.png");
    }

  }

}
