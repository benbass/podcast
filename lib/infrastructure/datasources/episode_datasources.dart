import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import '../../core/globals.dart';
import '../../domain/entities/episode_entity.dart';
import '../../domain/entities/podcast_entity.dart';
import '../../helpers/authorization/authorization.dart';
import '../../injection.dart';
import '../../objectbox.g.dart';
import '../models/episode_model.dart';

/// Local data source = objectBox database
abstract class EpisodeLocalDatasource {
  Stream<List<EpisodeEntity>> getEpisodes({
    required bool subscribed,
    required int feedId,
    required bool onlyUnread,
  });
  Stream<int> unreadLocalEpisodesCount({required int feedId});
}

class EpisodeLocalDatasourceImpl implements EpisodeLocalDatasource {
  @override
  Stream<List<EpisodeEntity>> getEpisodes({
    required bool subscribed,
    required int feedId,
    required bool onlyUnread,
  }) {
    if (subscribed) {
      if (onlyUnread) {
        return _getUnreadLocalEpisodesByFeedId(feedId);
      } else {
        return _getLocalEpisodesByFeedId(feedId);
      }
    } else {
      return getIt<EpisodeRemoteDataSource>()
          .fetchRemoteEpisodesByFeedId(feedId);
    }
  }

  Stream<List<EpisodeEntity>> _getLocalEpisodesByFeedId(int feedId) {
    final queryBuilder = episodeBox.query(EpisodeEntity_.feedId.equals(feedId))
      ..order(EpisodeEntity_.datePublished, flags: Order.descending);
    return queryBuilder
        .watch(triggerImmediately: true)
        .map((query) => query.find());
  }

  Stream<List<EpisodeEntity>> _getUnreadLocalEpisodesByFeedId(int feedId) {
    final queryBuilder = episodeBox.query(EpisodeEntity_.feedId
        .equals(feedId)
        .and(EpisodeEntity_.read.equals(false)))
      ..order(EpisodeEntity_.datePublished, flags: Order.descending);
    return queryBuilder
        .watch(triggerImmediately: true)
        .map((query) => query.find());
  }

  @override
  Stream<int> unreadLocalEpisodesCount({required int feedId}) {
    final queryBuilder = episodeBox.query(EpisodeEntity_.feedId
        .equals(feedId)
        .and(EpisodeEntity_.read.equals(false)));
    return queryBuilder
        .watch(triggerImmediately: true)
        .map((query) => query.count());
  }
}

/// Remote data source = http requests
abstract class EpisodeRemoteDataSource {
  Stream<List<EpisodeEntity>> fetchRemoteEpisodesByFeedId(int feedId);
  Stream<List<EpisodeEntity>> refreshEpisodes({
    required PodcastEntity podcast,
  });
}

class EpisodeRemoteDataSourceImpl implements EpisodeRemoteDataSource {
  final http.Client httpClient;

  EpisodeRemoteDataSourceImpl({required this.httpClient});
  @override
  Stream<List<EpisodeEntity>> fetchRemoteEpisodesByFeedId(int feedId) async* {
    // Authorization:
    Map<String, String> headers = headersForAuth(); // this is the real auth

    final Uri uri =
        Uri.parse('$baseUrl/episodes/byfeedid?id=$feedId&pretty&max=1000');

    final response = await httpClient.get(uri, headers: headers);
    if (response.statusCode == 200) {
      var jsonItems = json.decode(response.body);
      List<EpisodeEntity> episodes = List<EpisodeEntity>.from(
          jsonItems['items'].map((x) => EpisodeModel.fromJson(x)));

      yield episodes;
    } else {
      print(
          "Error Episode datasource fetchEpisodesAsStreamByFeedId: ${response.statusCode}");
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load episodes');
    }
  }

  @override
  Stream<List<EpisodeEntity>> refreshEpisodes({
    required PodcastEntity podcast,
  }) async* {
    final List<EpisodeEntity> currentEpisodes = podcast.episodes;
    final Set<int> currentEpisodeIds =
        currentEpisodes.map((ep) => ep.eId).toSet();
    final List<EpisodeEntity> allEpisodesOnRemote =
        await fetchRemoteEpisodesByFeedId(podcast.pId).first;
    final List<EpisodeEntity> newEpisodes = allEpisodesOnRemote
        .where((episode) => !currentEpisodeIds.contains(episode.eId))
        .toList()
      ..sort((a, b) => a.datePublished.compareTo(b.datePublished));
    podcast.episodes.insertAll(0, newEpisodes);
    if (podcast.subscribed) {
      podcast.episodes
          .applyToDb(); // applyToDb() updates relation only which is more efficient than box.put(object)
    }
    yield podcast.episodes;
  }
}
