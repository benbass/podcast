import 'dart:async';

import 'package:flutter/material.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;

class MyImageProvider {
  final String url;

  static final Set<String> _verifiedUrls = {};

  MyImageProvider({required this.url});

  static const List<String> _imageExtensions = [
    '.jpg',
    '.jpeg',
    '.png',
    '.gif',
    '.webp',
    '.bmp',
    '.heic',
    '.heif'
  ];

  Future<ImageProvider> get imageProvider async {
    if (url.isEmpty) {
      return const AssetImage("assets/placeholder.png");
    }
    if (_verifiedUrls.contains(url)) {
      return NetworkImage(url);
    }

    if (url.startsWith('http')) {
      return _getImageFromNetwork(url);
    } else {
      return _getImageFromFile(url);
    }
  }

  Future<ImageProvider> _getImageFromNetwork(String url) async {
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {'Range': 'bytes=0-0'}, // Only check the first byte
      ).timeout(const Duration(seconds: 5)); // Timeout

      final contentType = response.headers['content-type']?.toLowerCase();

      bool isLikelyImageByExtension = false;

      try {
        final uri = Uri.parse(url);
        String extension = p.extension(uri.path).toLowerCase();
        if (_imageExtensions.contains(extension)) {
          isLikelyImageByExtension = true;
        }
      } catch (e) {
        debugPrint('Could not parse extension from URL: $url - $e');
      }

      if (response.statusCode == 200 || response.statusCode == 206) {
        // 206: Partial Content

        if (contentType != null && contentType.startsWith('image/')) {
          // valid image: add it to the verifiedUrls set
          _verifiedUrls.add(url);
          return NetworkImage(url);
        } else if (contentType != null && contentType.startsWith('binary/')) {
          return NetworkImage(url);
        } else if (contentType != null &&
            contentType == 'application/octet-stream' &&
            isLikelyImageByExtension) {
          return NetworkImage(url);
        } else {
          debugPrint('Invalid Content-Type: $contentType for URL: $url');
          return const AssetImage("assets/placeholder.png");
        }
      } else if (response.statusCode == 404) {
        debugPrint('Image not found (404): $url');
      } else {
        debugPrint(
            'Error fetching image: ${response.statusCode} for URL: $url');
      }
    } on TimeoutException catch (_) {
      debugPrint('Timeout fetching image for URL: $url');
    } on http.ClientException catch (e) {
      debugPrint('Network error fetching image: $e for URL: $url');
    } catch (e) {
      debugPrint('Unknown error fetching image: $e for URL: $url');
    }
    return const AssetImage("assets/placeholder.png");
  }

  Future<ImageProvider> _getImageFromFile(String path) async {
    try {
      final file = File(path);
      if (file.existsSync()) {
        return FileImage(file);
      } else {
        debugPrint('File not found: $path');
      }
    } on FileSystemException catch (e) {
      debugPrint('File system error: $e for path: $path');
    } catch (e) {
      debugPrint('Unknown error accessing file: $e for path: $path');
    }
    return const AssetImage("assets/placeholder.png");
  }
}
