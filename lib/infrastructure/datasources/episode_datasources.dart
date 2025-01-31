import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import '../../core/globals.dart';
import '../../domain/entities/episode_entity.dart';
import '../../helpers/authorization/authorization.dart';
import '../models/episode_model.dart';

abstract class EpisodeDataSources {
  Stream<List<EpisodeEntity>> fetchEpisodesAsStreamByFeedId(int id);
  Future<List<EpisodeEntity>> fetchEpisodesByFeedId(int id);
}

class EpisodeDataSourcesImpl implements EpisodeDataSources {
  final http.Client httpClient;

  EpisodeDataSourcesImpl({required this.httpClient});
  @override
  Stream<List<EpisodeEntity>> fetchEpisodesAsStreamByFeedId(int id) async* {
    // Authorization:
    Map<String, String> headers = headersForAuth(); // this is the real auth

    final response = await httpClient.get(
        Uri.parse('$baseUrl/episodes/byfeedid?id=$id&pretty&max=1000'),
        headers: headers);
    if (response.statusCode == 200) {
      var jsonItems = json.decode(response.body);
      List<EpisodeEntity> episodes = List<EpisodeEntity>.from(
          jsonItems['items'].map((x) => EpisodeModel.fromJson(x)));

      yield episodes;
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load episodes');
    }
  }

  @override
  Future<List<EpisodeEntity>> fetchEpisodesByFeedId(int id) async {
    // Authorization:
    Map<String, String> headers = headersForAuth(); // this is the real auth

    final response = await httpClient.get(
        Uri.parse('$baseUrl/episodes/byfeedid?id=$id&pretty&max=1000'),
        headers: headers);
    if (response.statusCode == 200) {
      var jsonItems = json.decode(response.body);
      List<EpisodeEntity> episodes = List<EpisodeEntity>.from(
          jsonItems['items'].map((x) => EpisodeModel.fromJson(x)));

      return episodes;
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load episodes');
    }
  }
}
