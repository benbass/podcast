import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:dartz/dartz.dart' as dartz;

import 'package:podcast/core/error/failure.dart';
import '../../core/globals.dart';
import '../../domain/entities/episode_entity.dart';
import '../../domain/entities/persistent_podcast_settings_entity.dart';
import '../../domain/entities/podcast_entity.dart';
import '../../domain/entities/podcast_filter_settings_entity.dart';
import '../../helpers/authorization/authorization.dart';
import '../../injection.dart';
import '../../objectbox.g.dart';
import '../models/episode_model.dart';

/// Local data source = objectBox database
abstract class EpisodeLocalDatasource {

  Stream<List<EpisodeEntity>> getEpisodesStream({
    required int feedId,
    required bool isSubscribed,
    required PodcastFilterSettingsEntity filterSettings,
  });

  Stream<EpisodeEntity?> getEpisodeStream({required int episodeId});

  Stream<int> unreadLocalEpisodesCount(
      {required int feedId});
}

class EpisodeLocalDatasourceImpl implements EpisodeLocalDatasource {

  @override
  Stream<EpisodeEntity?> getEpisodeStream({required int episodeId}) {
    final queryBuilder = episodeBox.query(EpisodeEntity_.id.equals(episodeId));
    return queryBuilder.watch(triggerImmediately: true).map((query) {
      final results = query.find();
      if (results.isNotEmpty) {
        return results.first;
      } else {
        return null;
      }
    });
  }

  @override
  Stream<int> unreadLocalEpisodesCount({required int feedId}) {
    final podcastQuery =
        podcastBox.query(PodcastEntity_.pId.equals(feedId)).build();
    final PodcastEntity? podcast = podcastQuery.findFirst();
    podcastQuery.close();

    /// 1. Load persistent filter settings for this podcast
    PersistentPodcastSettingsEntity? persistentSettings;
    if (podcast != null) {
      persistentSettings = podcast.persistentSettings.target;
      persistentSettings ??=
          PersistentPodcastSettingsEntity.defaultPersistentSettings(feedId);
    }

    late QueryBuilder<EpisodeEntity> queryBuilder;
    // Base condition for the query
    Condition<EpisodeEntity> baseCondition = EpisodeEntity_.feedId
        .equals(feedId)
        .and(EpisodeEntity_.read.equals(false));

    // Integrate persistent filter settings to the baseCondition
    if (persistentSettings != null) {
      if (persistentSettings.filterExplicitEpisodes) {
        // Only episodes that are not explicit (or explicit = 0)
        baseCondition = baseCondition.and(EpisodeEntity_.explicit.notEquals(1));
      }
      if (persistentSettings.filterTrailerEpisodes) {
        // Only episodes that are not trailer (or episodeType = "trailer")
        baseCondition =
            baseCondition.and(EpisodeEntity_.episodeType.notEquals("trailer"));
      }
      if (persistentSettings.filterBonusEpisodes) {
        // Only episodes that are not bonus (or episodeType = "bonus")
        baseCondition =
            baseCondition.and(EpisodeEntity_.episodeType.notEquals("bonus"));
      }
      if (persistentSettings.minEpisodeDurationMinutes != null &&
          persistentSettings.minEpisodeDurationMinutes! > 0) {
        final minDurationSeconds =
            persistentSettings.minEpisodeDurationMinutes! * 60;
        baseCondition = baseCondition
            .and(EpisodeEntity_.duration.greaterThan(minDurationSeconds));
      }
    }

    queryBuilder = episodeBox.query(baseCondition);
    return queryBuilder
        .watch(triggerImmediately: true)
        .map((query) => query.count());
  }

  @override
  Stream<List<EpisodeEntity>> getEpisodesStream({
    required int feedId,
    required bool isSubscribed,
    required PodcastFilterSettingsEntity filterSettings,
  }) async* {
    if (!isSubscribed) {
      // If not subscribed, fetch episodes from the remote data source.
      // And save them to the local database.
      // These episodes will be deleted from the database at app close if the podcast stays unsubscribed.

      // User may have called the episode list already: check this first.
      final queryForCachedEpisodes =
          episodeBox.query(EpisodeEntity_.feedId.equals(feedId));
      final queryBuilderForCachedEpisodes = queryForCachedEpisodes.build();
      final cachedEpisodes = queryBuilderForCachedEpisodes.find();
      queryBuilderForCachedEpisodes.close();

      if (cachedEpisodes.isEmpty) {
        await getIt<EpisodeRemoteDataSource>()
            .fetchRemoteEpisodesByFeedIdAndSaveToDb(
                feedId: feedId);
      }
    }

    // Base condition
    Condition<EpisodeEntity> queryCondition =
        EpisodeEntity_.feedId.equals(feedId);

    // --- PERSISTENT FILTER SETTINGS ---
    if (filterSettings.filterExplicitEpisodes) {
      queryCondition = queryCondition.and(EpisodeEntity_.explicit.notEquals(1));
    }
    if (filterSettings.filterTrailerEpisodes) {
      queryCondition =
          queryCondition.and(EpisodeEntity_.episodeType.notEquals("trailer"));
    }
    if (filterSettings.filterBonusEpisodes) {
      queryCondition =
          queryCondition.and(EpisodeEntity_.episodeType.notEquals("bonus"));
    }
    if (filterSettings.minEpisodeDurationMinutes != null &&
        filterSettings.minEpisodeDurationMinutes! > 0) {
      final int minDurationMinutes = filterSettings.minEpisodeDurationMinutes!;
      final int minDurationSeconds = minDurationMinutes * 60;
      queryCondition = queryCondition
          .and(EpisodeEntity_.duration.greaterThan(minDurationSeconds));
    }

    // --- DYNAMIC UI-FILTER ---
    // Default: read episodes are hidden
    if (filterSettings.filterRead) {
      queryCondition = queryCondition.and(EpisodeEntity_.read.equals(false));
    }
    if (filterSettings.showOnlyRead) {
      queryCondition = queryCondition.and(EpisodeEntity_.read.equals(true));
    } else if (filterSettings.showOnlyFavorites) {
      queryCondition = queryCondition.and(EpisodeEntity_.favorite.equals(true));
    } else if (filterSettings.showOnlyDownloaded) {
      queryCondition = queryCondition.and(EpisodeEntity_.filePath
          .notNull()
          .and(EpisodeEntity_.filePath.notEquals("")));
    } else if (filterSettings.showOnlyUnfinished) {
      queryCondition = queryCondition.and(
          (EpisodeEntity_.position > 0).and(EpisodeEntity_.read.equals(false)));
    } else if (filterSettings.filterByText &&
        filterSettings.transientSearchText != null &&
        filterSettings.transientSearchText!.isNotEmpty) {
      final searchText = filterSettings.transientSearchText!;
      queryCondition = queryCondition.and(
          (EpisodeEntity_.title.contains(searchText, caseSensitive: false)).or(
              EpisodeEntity_.description
                  .contains(searchText, caseSensitive: false)));
    }

    // Create the QueryBuilder with the final condition
    QueryBuilder<EpisodeEntity> queryBuilder = episodeBox.query(queryCondition);

    // --- SORT ---
    // We do not offer such a setting in the UI
    // We use default values: EpisodeEntity_.datePublished and Order.descending.
    // May be useful for future feature.
    int orderFlags = filterSettings.sortDirection == SortDirection.descending
        ? Order.descending
        : 0;
    switch (filterSettings.sortProperty) {
      case EpisodeSortProperty.datePublished:
        queryBuilder.order(EpisodeEntity_.datePublished, flags: orderFlags);
        break;
      case EpisodeSortProperty.duration:
        queryBuilder.order(EpisodeEntity_.duration, flags: orderFlags);
        break;
      case EpisodeSortProperty.title:
        queryBuilder.order(EpisodeEntity_.title,
            flags: orderFlags | Order.caseSensitive);
        break;
    }

    yield* queryBuilder.watch(triggerImmediately: true).map((query) {
      final foundEpisodes = query.find();
      return foundEpisodes;
    });
  }
}

/// Remote data source = http requests
abstract class EpisodeRemoteDataSource {

  Future<void> fetchRemoteEpisodesByFeedIdAndSaveToDb({
    required int feedId,
    bool? markAsSubscribed,
  });

  // Explicitly fetch new episodes from the server and save them to the local database.
  Future<void> refreshEpisodesFromServer({
    required int feedId,
  });
}

class EpisodeRemoteDataSourceImpl implements EpisodeRemoteDataSource {
  final http.Client httpClient;

  EpisodeRemoteDataSourceImpl({required this.httpClient});

  // This method is called only when podcast is not yet subscribed:
  // 1. WHEN podcast is being subscribed BEFORE episodes are fetched: we make episodes available in db.
  // 2. OR WHEN list of episodes is needed but podcast still is not subscribed: we "cache" the episodes in db.
  // In both cases, the episodes are saved to db, in the first case, the flag isSubscribed is set to true.
  @override
  Future<void> fetchRemoteEpisodesByFeedIdAndSaveToDb({
    required int feedId,
    bool? markAsSubscribed,
  }) async {
    // first check if episodes already exist in the database
    final queryBuilder = episodeBox.query(EpisodeEntity_.feedId.equals(feedId));
    final query = queryBuilder.build();
    final List<EpisodeEntity> localEpisodes = query.find();
    query.close();

    if (localEpisodes.isNotEmpty) {
      // Episodes already exist in the database.
      if (markAsSubscribed != null) {
        // Podcast is being subscribed
        List<EpisodeEntity> episodesToUpdate = [];
        for (var episode in localEpisodes) {
          if (episode.isSubscribed != markAsSubscribed) {
            episode.isSubscribed = true;
            episodesToUpdate.add(episode);
          }
        }
        if (episodesToUpdate.isNotEmpty) {
          episodeBox.putMany(episodesToUpdate);
        }
      }
      // Episodes exist and podcast is not being subscribed
      return;
    }

    // Episodes do not exist in the database:
    // fetch them from the server and save them to the database with updated parameters.
    dartz.Either<Failure, List<EpisodeEntity>> serverResponse =
        await _fetchRemoteEpisodesByFeedId(
            feedId: feedId);

    await serverResponse.fold(
      (failure) async {
        return;
      },
      (remoteEpisodes) async {
        if (remoteEpisodes.isEmpty) {
          return;
        }
        // Get the parent podcast for the given feed ID.
        final query =
            podcastBox.query(PodcastEntity_.pId.equals(feedId)).build();
        PodcastEntity? parentPodcast = query.findFirst();
        query.close();

        for (var episode in remoteEpisodes) {
          if (parentPodcast != null) {
            episode.podcast.target = parentPodcast;
          }
          if (markAsSubscribed != null) {
            // Podcast is being subscribed: update the isSubscribed flag.
            episode.isSubscribed = markAsSubscribed;
          }
        }

        // Save the fetched episodes to the database.
        episodeBox.putMany(remoteEpisodes);
      },
    );
  }


  Future<dartz.Either<Failure, List<EpisodeEntity>>>
      _fetchRemoteEpisodesByFeedId(
          {required int feedId}) async {
    // Authorization:
    Map<String, String> headers = headersForAuth();

    final Uri uri =
        Uri.parse('$baseUrl/episodes/byfeedid?id=$feedId&pretty&max=1000');

    try {
      final response = await httpClient
          .get(uri, headers: headers)
          .timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) {
        var jsonItems = json.decode(response.body);
        List<EpisodeEntity> episodes = List<EpisodeEntity>.from(
                jsonItems['items'].map((x) => EpisodeModel.fromJson(x)));

        return dartz.Right(episodes);
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        return dartz.Left(AuthenticationFailure(
            message: "Authentication failed: ${response.body}"));
      } else if (response.statusCode == 404) {
        return const dartz.Left(NotFoundFailure(
            message: "Podcast-Feed was not found at this URL."));
      } else {
        return dartz.Left(ServerFailure(
            message: "Server error: ${response.body}",
            statusCode: response.statusCode));
      }
    } on TimeoutException catch (e, s) {
      return dartz.Left(NetworkFailure(
          message: "Timeout during the request to the server:", stackTrace: s));
    } on http.ClientException catch (e, s) {
      return dartz.Left(NetworkFailure(
          message: "Network error: ${e.message}", stackTrace: s));
    } on FormatException catch (e, s) {
      // When json.decode fails
      return dartz.Left(ServerFailure(
          message: "Error processing the server response (invalid format).",
          stackTrace: s));
    } catch (e, s) {
      return dartz.Left(
          UnexpectedFailure(message: e.toString(), stackTrace: s));
    }
  }

  @override
  Future<void> refreshEpisodesFromServer({
    required int feedId,
  }) async {
    await _fetchAndSaveNewEpisodesByFeedId(
      feedId: feedId,
    );
  }

  Future<void> _fetchAndSaveNewEpisodesByFeedId(
      {required int feedId}) async {
    dartz.Either<Failure, List<EpisodeEntity>> response =
    await _fetchRemoteEpisodesByFeedId(
      feedId: feedId
    );
    List<EpisodeEntity> remoteEpisodes = response.fold((failure) {
      return [];
    }, (episodes) {
      return episodes;
    });

    // Get the IDs of episodes currently stored locally for this feed ID.
    final Set<int> localEpisodeIds =
    _getLocalEpisodeIdsByFeedId(feedId: feedId);

    // Filter out remote episodes that are already in the database.
    final List<EpisodeEntity> newEpisodes = remoteEpisodes
        .where((episode) => !localEpisodeIds.contains(episode.eId))
        .toList();

    // Get the parent podcast for the given feed ID.
    final query = podcastBox.query(PodcastEntity_.pId.equals(feedId)).build();
    PodcastEntity? parentPodcast = query.findFirst();
    query.close();

    // Add the new episodes to the local database.
    if (newEpisodes.isNotEmpty) {
      final List<EpisodeEntity> newEpisodesSubscribed = [];
      for (var episode in newEpisodes) {
        episode.isSubscribed = true;
        if (parentPodcast != null) {
          episode.podcast.target = parentPodcast;
        }
        newEpisodesSubscribed.add(episode);
      }

      episodeBox.putMany(newEpisodesSubscribed);
    }
  }

// Helper function to get local episode IDs for a given feed ID.
  Set<int> _getLocalEpisodeIdsByFeedId({required int feedId}) {
    return _getLocalEpisodesByFeedId(feedId: feedId)
        .map((ep) => ep.eId)
        .toSet();
  }

  // This gets all episodes (unfiltered!) from db
  List<EpisodeEntity> _getLocalEpisodesByFeedId({required int feedId}) {
    final queryBuilder =
    episodeBox.query(EpisodeEntity_.feedId.equals(feedId)).build();
    final results = queryBuilder.find();
    return results;
  }
}
