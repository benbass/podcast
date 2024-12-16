import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:podcast/domain/entities/episode_query_entity.dart';
import '../../domain/entities/episode_entity.dart';
import '../../helpers/authorization/authorization.dart';

abstract class EpisodeQueryDataSources {
  Future<List<EpisodeEntity>> fetchEpisodesByFeedId(int id);
}

class EpisodeQueryDataSourcesImpl implements EpisodeQueryDataSources {
  @override
  Future<List<EpisodeEntity>> fetchEpisodesByFeedId(int id) async {
    // Authorization
    Map<String, String> headers = headersForAuth();

    final response = await http.get(
        Uri.parse(
            'https://api.podcastindex.org/api/1.0/episodes/byfeedid?id=$id&pretty'),
        headers: headers);

    if (response.statusCode == 200) {

      EpisodeQuery episodeQuery =
      EpisodeQuery.fromJson(json.decode(response.body));
      return episodeQuery.episodes;
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load episodes');
    }


  }
}
