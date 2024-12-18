import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../domain/entities/podcast_entity.dart';
import '../../domain/entities/podcast_query_entity.dart';
import '../../helpers/authorization/authorization.dart';

abstract class PodcastQueryDataSources {
  Future<List<PodcastEntity>> fetchPodcastsByKeywords(String keyword);
}

class PodcastQueryDataSourceImpl implements PodcastQueryDataSources {
  @override
  Future<List<PodcastEntity>> fetchPodcastsByKeywords(String keyword) async {
    // Preparing keyword for web search
    String searchKeyword = keyword.trim().replaceAll(' ', '+');

    // Authorization
    Map<String, String> headers = headersForAuth();

    final response = await http.get(
        Uri.parse(
            'https://api.podcastindex.org/api/1.0/search/byterm?q=$searchKeyword&pretty&max=1000'),
        headers: headers);

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      PodcastQuery podCastSearchQuery =
          PodcastQuery.fromJson(json.decode(response.body));
      return podCastSearchQuery.podcasts;
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load podcasts');
    }
  }
}
