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
    final results = queryBuilder
        .watch(triggerImmediately: true)
        .map((query) => query.find());
    return results;
  }
}

abstract class EpisodeLocalDatasource extends _BaseEpisodeLocalDatasource {
  Stream<List<EpisodeEntity>> getEpisodes({
    required bool subscribed,
    required int feedId,
    required String podcastTitle,
    required bool showRead,
    required bool refresh,
  });
  Stream<int> unreadLocalEpisodesCount(
      {required int feedId}); // this is only needed for subscribed = true
  Stream<Map<String, List<EpisodeEntity>>> getFlaggedEpisodes(
      {required String flag});
}

class EpisodeLocalDatasourceImpl extends _BaseEpisodeLocalDatasource
    implements EpisodeLocalDatasource {
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
    } else if (flag == "In Progress") {
      queryBuilder = episodeBox.query(
          (EpisodeEntity_.position > 0).and(EpisodeEntity_.read.equals(false)));
    } else if (flag == "Read") {
      queryBuilder = episodeBox.query(
          (EpisodeEntity_.position > 0).and(EpisodeEntity_.read.equals(true)));
    } else {
      queryBuilder = episodeBox.query(EpisodeEntity_.id.equals(-100));
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

  Future<List<EpisodeEntity>> _fetchRemoteEpisodes(
      {required int feedId, required String podcastTitle}) async {
    List<EpisodeEntity> remoteEpisodes = [];
    try {
      // Fetch episodes from the remote data source.
      remoteEpisodes = await getIt<EpisodeRemoteDataSource>()
          .fetchRemoteEpisodesByFeedId(feedId: feedId, podcastTitle: podcastTitle);
    } catch (e) {
      remoteEpisodes = [];
    }

    // Retrieve locally stored episodes for the given feed ID.
    final localEpisodes = _getLocalEpisodesByFeedId(feedId: feedId);

    // Create a map of local episodes for efficient lookup by episode ID.
    final localEpisodeMap = {for (final episode in localEpisodes) episode.eId: episode};

    // Merge remote episodes with local data, prioritizing local versions if available.
    return remoteEpisodes.map((remoteEpisode) {
      // If a local episode with the same ID exists, return the local episode;
      // otherwise, return the remote episode.
      return localEpisodeMap[remoteEpisode.eId] ?? remoteEpisode;
    }).toList();
  }

  @override
  Stream<List<EpisodeEntity>> getEpisodes({
    required bool subscribed,
    required int feedId,
    required String podcastTitle,
    required bool showRead,
    required bool refresh,
  }) async* {
    if (!subscribed) {
      yield* _fetchRemoteEpisodes(
              feedId: feedId, podcastTitle: podcastTitle)
          .asStream();
    } else {
      if (refresh) {
        await _getNewEpisodesByFeedId(
            feedId: feedId, podcastTitle: podcastTitle);
      }
      yield* _getEpisodesByFeedId(feedId, showRead: showRead);
    }
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
  List<EpisodeEntity> _getLocalEpisodesByFeedId({required int feedId}) {
    final queryBuilder =
        episodeBox.query(EpisodeEntity_.feedId.equals(feedId)).build();
    final results = queryBuilder.find();
    return results;
  }

  // Helper function to get local episode IDs for a given feed ID.
  Set<int> _getLocalEpisodeIdsByFeedId({required int feedId}) {
    return _getLocalEpisodesByFeedId(feedId: feedId).map((ep) => ep.eId).toSet();
  }

  Future<void> _getNewEpisodesByFeedId(
      {required int feedId, required String podcastTitle}) async {
    List<EpisodeEntity> remoteEpisodes = [];
    try {
      // Fetch episodes from remote for the given podcast feed ID.
      remoteEpisodes = await getIt<EpisodeRemoteDataSource>()
          .fetchRemoteEpisodesByFeedId(feedId: feedId, podcastTitle: podcastTitle);
    } catch (e) {
      remoteEpisodes = [];
    }

    // Get the IDs of episodes currently stored locally for this feed ID.
    final localEpisodeIds = _getLocalEpisodeIdsByFeedId(feedId: feedId);

    // Filter out remote episodes that are already in the database.
    final newEpisodes = remoteEpisodes
        .where((episode) => !localEpisodeIds.contains(episode.eId))
        .toList();

    // Add the new episodes to the local database.
    if (newEpisodes.isNotEmpty) {
      episodeBox.putMany(newEpisodes);
    }
  }
}

/// Remote data source = http requests
abstract class EpisodeRemoteDataSource {
  Future<List<EpisodeEntity>> fetchRemoteEpisodesByFeedId(
      {required int feedId, required String podcastTitle});
}

class EpisodeRemoteDataSourceImpl implements EpisodeRemoteDataSource {
  final http.Client httpClient;

  EpisodeRemoteDataSourceImpl({required this.httpClient});
  @override
  Future<List<EpisodeEntity>> fetchRemoteEpisodesByFeedId(
      {required int feedId, required String podcastTitle}) async {
    // Authorization:
    Map<String, String> headers = headersForAuth(); // this is the real auth

    // The following code allows to check some podcasts that actually have live episodes:
    // uri is specific!
    /*
    final Uri uriLive = Uri.parse('$baseUrl/episodes/live?pretty&max=20');
    final responseLive = await httpClient.get(uriLive, headers: headers);
    if(responseLive.statusCode == 200) {
      var jsonItems = json.decode(responseLive.body);
      Map<String, dynamic> myData = {'items': jsonItems['items']};
      final encoder = JsonEncoder.withIndent('  ');
      String prettyJson = encoder.convert(myData);
      debugPrint(prettyJson);
    }
    */

    final Uri uri =
        Uri.parse('$baseUrl/episodes/byfeedid?id=$feedId&pretty&max=1000');

    final response = await httpClient.get(uri, headers: headers);
    if (response.statusCode == 200) {
      var jsonItems = json.decode(response.body);
      List<EpisodeEntity> episodes = List<EpisodeEntity>.from(
              jsonItems['items'].map((x) => EpisodeModel.fromJson(x)))
          .map((e) => e.copyWith(podcastTitle: podcastTitle))
          .toList();

      //episodeBox.putMany(episodes);

      /*
      // Test for retrieving live items from current podcast (for future feature).
      // the feature doesn't seem to be supported yet by many podcast providers:
      // jsonItems['liveItems'] is too often an empty list!
      Map<String, dynamic> myData = {'liveItems': jsonItems['liveItems']};
      final encoder = JsonEncoder.withIndent('  ');
      String prettyJson = encoder.convert(myData);
      debugPrint(prettyJson);
      */

      return episodes;
    } else {
      print(
          "Error Episode datasource fetchEpisodesAsStreamByFeedId: ${response.statusCode}");
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load episodes');
    }
  }
}
