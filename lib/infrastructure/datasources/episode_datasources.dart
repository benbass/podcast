import 'dart:convert';

import 'package:http/http.dart' as http;
import '../../domain/entities/episode_entity.dart';
import '../../helpers/authorization/authorization.dart';
import '../models/episode_model.dart';

abstract class EpisodeDataSources {
  Future<List<EpisodeEntity>> fetchEpisodesByFeedId(int id);
}

class EpisodeDataSourcesImpl implements EpisodeDataSources {
  @override
  Future<List<EpisodeEntity>> fetchEpisodesByFeedId(int id) async {
    // Authorization
    Map<String, String> headers = headersForAuth();

    final response = await http.get(
        Uri.parse(
            'https://api.podcastindex.org/api/1.0/episodes/byfeedid?id=$id&pretty&max=1000'),
        headers: headers);

    if (response.statusCode == 200) {
      var jsonItems = json.decode(response.body);
      List<EpisodeEntity> episodes = List<EpisodeModel>.from(jsonItems['items'].map((x) => EpisodeModel.fromJson(x)));
      return episodes;
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load episodes');
    }


  }
}
