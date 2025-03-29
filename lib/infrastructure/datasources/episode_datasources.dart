import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import '../../core/globals.dart';
import '../../domain/entities/episode_entity.dart';
import '../../helpers/authorization/authorization.dart';
import '../../injection.dart';
import '../../objectbox.g.dart';
import '../models/episode_model.dart';

/// Local data source = objectBox database
abstract class _BaseEpisodeLocalDatasource {
  Stream<List<EpisodeEntity>> _getEpisodesByFeedId(int feedId,
      {required bool showRead}) {
    // If showRead is true (initial is false), we show all episodes, otherwise only unread ones
    final queryBuilder = episodeBox.query(EpisodeEntity_.feedId
        .equals(feedId)
        .and(showRead
            ? EpisodeEntity_.read.notNull()
            : EpisodeEntity_.read.equals(false)))
      ..order(EpisodeEntity_.datePublished, flags: Order.descending);
    return queryBuilder
        .watch(triggerImmediately: true)
        .map((query) => query.find());
  }
}

abstract class EpisodeLocalDatasource extends _BaseEpisodeLocalDatasource {
  Stream<List<EpisodeEntity>> getEpisodes({
    required bool subscribed,
    required int feedId,
    required String podcastTitle,
    required bool showRead,
  });
  Stream<int> unreadLocalEpisodesCount(
      {required int feedId}); // this is only needed for subscribed = true
  Future<List<EpisodeEntity>> getNewEpisodesByFeedId(
      {required int feedId, required String podcastTitle});
  Stream<List<EpisodeEntity>> getLocalEpisodesFromUnsubscribedPodcastByFeedId(
      {required int feedId});
  Stream<Map<String, List<EpisodeEntity>>> getFlaggedEpisodes(
      {required String flag});
}

class EpisodeLocalDatasourceImpl extends _BaseEpisodeLocalDatasource
    implements EpisodeLocalDatasource {
  @override
  Stream<List<EpisodeEntity>> getLocalEpisodesFromUnsubscribedPodcastByFeedId(
      {required int feedId}) {
    final queryBuilder = episodeBox.query(EpisodeEntity_.feedId.equals(feedId))
      ..order(EpisodeEntity_.datePublished, flags: Order.descending);
    return queryBuilder
        .watch(triggerImmediately: true)
        .map((query) => query.find());
  }

  @override
  Stream<Map<String, List<EpisodeEntity>>> getFlaggedEpisodes(
      {required String flag}) {
    late QueryBuilder<EpisodeEntity> queryBuilder;
    if (flag == "Favorites") {
      queryBuilder = episodeBox.query(EpisodeEntity_.favorite.equals(true))
        ..order(EpisodeEntity_.datePublished, flags: Order.descending);
    } else if (flag == "Downloads") {
      queryBuilder = episodeBox.query(EpisodeEntity_.filePath.notNull())
        ..order(EpisodeEntity_.datePublished, flags: Order.descending);
    } else {
      queryBuilder = episodeBox.query(EpisodeEntity_.position.notNull())
        ..order(EpisodeEntity_.datePublished, flags: Order.descending);
    }

    return queryBuilder
        .watch(triggerImmediately: true)
        .map((query) => query.find())
        .map((episodes) {
      final Map<String, List<EpisodeEntity>> groupedEpisodes = {};
      for (final episode in episodes) {
        final podcastTitle = episode.podcastTitle;
        if (groupedEpisodes.containsKey(podcastTitle)) {
          groupedEpisodes[podcastTitle]!.add(episode);
        } else {
          groupedEpisodes[podcastTitle] = [episode];
        }
      }
      return groupedEpisodes;
    });
  }

  Stream<List<EpisodeEntity>> _fetchRemoteEpisodes(
      {required int feedId, required String podcastTitle}) async* {
    // This is the real fetch from remote
    List<EpisodeEntity> remoteEpisodes = await getIt<EpisodeRemoteDataSource>()
        .fetchRemoteEpisodesByFeedId(feedId: feedId, podcastTitle: podcastTitle)
        .first;

    // User may have viewed this podcast already and marked some episodes as favorite, or downloaded some
    List<EpisodeEntity> localEpisodes =
        await getLocalEpisodesFromUnsubscribedPodcastByFeedId(feedId: feedId)
            .first;

    final Map<int, EpisodeEntity> localEpisodeMap = {
      for (var e in localEpisodes) e.eId: e
    };
    // Replace remote episodes with local ones if they exist
    remoteEpisodes = remoteEpisodes.map((episode) {
      final localEpisode = localEpisodeMap[episode.eId];
      return localEpisode ??
          episode; // Use local if exists, otherwise use remote
    }).toList();
    yield remoteEpisodes;
  }

  @override
  Stream<List<EpisodeEntity>> getEpisodes({
    required bool subscribed,
    required int feedId,
    required String podcastTitle,
    required bool showRead,
  }) {
    return subscribed
        ? _getEpisodesByFeedId(feedId, showRead: showRead)
        : _fetchRemoteEpisodes(feedId: feedId, podcastTitle: podcastTitle);
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

  // This gets all episodes (unfiltered!) from db
  Future<List<EpisodeEntity>> _getLocalEpisodesByFeedId(
      {required int feedId}) async {
    final queryBuilder = episodeBox.query(EpisodeEntity_.feedId.equals(feedId))
      ..order(EpisodeEntity_.datePublished, flags: Order.descending);
    return queryBuilder.build().find();
  }

  @override
  Future<List<EpisodeEntity>> getNewEpisodesByFeedId(
      {required int feedId, required String podcastTitle}) async {
    final List<EpisodeEntity> currentLocalEpisodes =
        await _getLocalEpisodesByFeedId(feedId: feedId);

    List<EpisodeEntity> currentEpisodesOnRemote =
        await getIt<EpisodeRemoteDataSource>()
            .fetchRemoteEpisodesByFeedId(
                feedId: feedId, podcastTitle: podcastTitle)
            .first;

    final Set<int> currentEpisodeIds =
        currentLocalEpisodes.map((ep) => ep.eId).toSet();

    final List<EpisodeEntity> newEpisodes = currentEpisodesOnRemote
        .where((episode) => !currentEpisodeIds.contains(episode.eId))
        .toList()
      ..sort((a, b) => a.datePublished.compareTo(b.datePublished));

    return newEpisodes;
  }
}

/// Remote data source = http requests
abstract class EpisodeRemoteDataSource {
  Stream<List<EpisodeEntity>> fetchRemoteEpisodesByFeedId(
      {required int feedId, required String podcastTitle});
}

class EpisodeRemoteDataSourceImpl implements EpisodeRemoteDataSource {
  final http.Client httpClient;

  EpisodeRemoteDataSourceImpl({required this.httpClient});
  @override
  Stream<List<EpisodeEntity>> fetchRemoteEpisodesByFeedId(
      {required int feedId, required String podcastTitle}) async* {
    // Authorization:
    Map<String, String> headers = headersForAuth(); // this is the real auth

    final Uri uri =
        Uri.parse('$baseUrl/episodes/byfeedid?id=$feedId&pretty&max=1000');

    final response = await httpClient.get(uri, headers: headers);
    if (response.statusCode == 200) {
      var jsonItems = json.decode(response.body);
      List<EpisodeEntity> episodes = List<EpisodeEntity>.from(
              jsonItems['items'].map((x) => EpisodeModel.fromJson(x)))
          .map((e) => e.copyWith(podcastTitle: podcastTitle))
          .toList();

      yield episodes;
    } else {
      print(
          "Error Episode datasource fetchEpisodesAsStreamByFeedId: ${response.statusCode}");
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load episodes');
    }
  }
}
