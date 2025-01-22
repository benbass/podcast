import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import '../../core/globals.dart';
import '../../domain/entities/episode_entity.dart';
import '../../helpers/authorization/authorization.dart';
import '../models/episode_model.dart';

abstract class EpisodeDataSources {
  Stream<List<EpisodeEntity>> fetchEpisodesByFeedId(int id);
}

class EpisodeDataSourcesImpl implements EpisodeDataSources {
  @override
  Stream<List<EpisodeEntity>> fetchEpisodesByFeedId(int id) async* {
    // Authorization:
    Map<String, String> headers = headersForAuth(); // this is the real auth

    final response = await http.get(
        Uri.parse(
            '$baseUrl/episodes/byfeedid?id=$id&pretty&max=1000'),
        headers: headers);
    if (response.statusCode == 200) {
      var jsonItems = json.decode(response.body);
      List<EpisodeEntity> episodes = List<EpisodeEntity>.from(
          jsonItems['items'].map((x) => EpisodeModel.fromJson(x)));

      // we create an entity with fake values for UI tests
      EpisodeEntity epTest =
      episodes.first.copyWith(favorite: true, read: true, position: 2000);
      episodes.insert(0, epTest);

      yield episodes;
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load episodes');
    }
  }
}

