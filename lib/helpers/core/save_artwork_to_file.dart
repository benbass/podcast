import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:image/image.dart' as img;

Future<String?> saveArtworkToFile(String artworkUrl) async {
  // 1. Validate url
  if (!Uri.parse(artworkUrl).isAbsolute) {
    return null;
  }

  // 2. Define file name
  final uri = Uri.parse(artworkUrl);
  final filename = path.basename(uri.path);

  // 3. Define app directory
  final appDir = await getApplicationDocumentsDirectory();
  // 4. Create the "artworks" directory (if it doesn't exist)
  final artworksDir = Directory('${appDir.path}/artworks');
  if (!artworksDir.existsSync()) {
    await artworksDir.create(recursive: true);
  }

  // 5. Define the full path for the file
  final file = File('${artworksDir.path}/$filename');

  // 6. Download the file
  final response = await http.get(uri);
  if (response.statusCode == 200) {
    // 7. Resize the image
    final originalImage = img.decodeImage(response.bodyBytes);
    if (originalImage == null) {
      return null;
    }
    final resizedImage = img.copyResize(
      originalImage,
      height: 600,
      interpolation: img.Interpolation.cubic,
    );

    // 8. Save the resized image
    await file.writeAsBytes(img.encodePng(resizedImage));

    // 8. Return the file path
    return file.path;
  } else {
    // 9. Handle errors
    return null;
  }
}
