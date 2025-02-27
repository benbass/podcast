import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class MyImageProvider {
  final String url;

  MyImageProvider({required this.url});

  Future<ImageProvider> get imageProvider async {
    if (url.isEmpty) {
      return const AssetImage("assets/placeholder.png");
    }

    final response = await http.head(Uri.parse(url));

    if (response.statusCode == 404) {
      return const AssetImage("assets/placeholder.png");
    }

    if (response.statusCode != 200) {
        // Handle other non-200 status codes (e.g., 500) if needed
        return const AssetImage("assets/placeholder.png");
      }

    return NetworkImage(url);

  }

}
