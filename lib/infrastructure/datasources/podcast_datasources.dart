import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:podcast/core/globals.dart';

import '../../domain/entities/podcast_entity.dart';
import '../../helpers/authorization/authorization.dart';
import '../models/podcast_model.dart';

abstract class PodcastDataSources {
  Future<List<PodcastEntity>> fetchPodcastsByKeywords(String keyword);
}

class PodcastDataSourceImpl implements PodcastDataSources {
  @override
  Future<List<PodcastEntity>> fetchPodcastsByKeywords(String keyword) async {
    // Preparing keyword for web search
    String searchKeyword = keyword.trim().replaceAll(' ', '+');

    // Authorization
    Map<String, String> headers = headersForAuth();

    final response = await http.get(
        Uri.parse(
            '$baseUrl/search/byterm?q=$searchKeyword&pretty&max=1000'),
        headers: headers);

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      var jsonFeed = json.decode(response.body);
      return List<PodcastModel>.from(jsonFeed['feeds'].map((feed) => PodcastModel.fromJson(feed)));
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load podcasts');
    }
  }
}
