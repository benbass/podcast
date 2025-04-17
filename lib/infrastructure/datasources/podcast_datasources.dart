import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:podcast/core/globals.dart';

import '../../domain/entities/podcast_entity.dart';
import '../../helpers/authorization/authorization.dart';
import '../models/podcast_model.dart';

abstract class PodcastDataSource {
  /// Fetches podcasts based on a keyword, considering subscribed podcasts.
  Future<List<PodcastEntity>> fetchPodcastsByKeyword(String keyword);

  /// Fetch trending podcasts
  Future<List<PodcastEntity>> fetchTrendingPodcasts();

  /// Fetch a podcast by its known feedId
  Future<PodcastEntity> fetchPodcastByFeedId(int feedId);

  /// Retrieves the list of subscribed podcasts.
  Future<List<PodcastEntity>?> getSubscribedPodcasts();
}

class PodcastDataSourceImpl implements PodcastDataSource {
  final http.Client httpClient;

  PodcastDataSourceImpl({required this.httpClient});

  Future<List<PodcastEntity>> _fetchPodcastsByEntryPoint(
      String entryPoint) async {
    // Authorization headers
    Map<String, String> headers = headersForAuth();

    final Uri uri = Uri.parse('$baseUrl/$entryPoint');
    final response = await httpClient.get(uri, headers: headers);

    if (response.statusCode == 200) {
      // Parse the JSON response if the server returns a 200 OK status code.
      final Map<String, dynamic> jsonFeed = json.decode(response.body);
      final List<dynamic> feeds = jsonFeed['feeds'];
      // Convert the JSON feeds to PodcastModel objects, then explicitly convert them to PodcastEntity objects.
      // Explicit conversion is necessary because the list of podcasts can change during the application's lifetime.
      // Mixing PodcastEntity and PodcastModel types would lead to inconsistencies.
      final List<PodcastEntity> podcasts = feeds
          .map((feed) => PodcastModel.fromJson(feed).toPodcastEntity())
          .toList();

      if (entryPoint.contains('search/byterm')) {
        // Merge the found podcasts with subscribed podcasts, giving precedence to subscribed ones.
        return _mergeWithSubscribedPodcasts(podcasts);
      } else {
        return podcasts;
      }
    } else {
      String errorMessage = '';
      if (entryPoint.contains('search/byterm')) {
        errorMessage =
            'Failed to load podcasts by keyword: Status code ${response.statusCode}';
      } else {
        errorMessage =
            'Failed to load trending podcasts: Status code ${response.statusCode}';
      }
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception(errorMessage);
    }
  }

  /// Fetches podcasts based on a keyword, considering subscribed podcasts.
  @override
  Future<List<PodcastEntity>> fetchPodcastsByKeyword(String keyword) async {
    // Prepare keyword for url
    String encodedKeyword = _encodeKeywordForUrl(keyword);
    // fetch podcasts by keyword
    String entryPoint = 'search/byterm?q=$encodedKeyword&pretty&max=1000';
    return _fetchPodcastsByEntryPoint(entryPoint);
  }

  @override
  Future<List<PodcastEntity>> fetchTrendingPodcasts() async {
    String languageCode = "de";
    String entryPoint = 'podcasts/trending?lang=$languageCode&pretty&max=10';
    return _fetchPodcastsByEntryPoint(entryPoint);

    // To do?: dynamically insert language code based on app language?
  }

  /// Fetch a podcast by its known feedId
  @override
  Future<PodcastEntity> fetchPodcastByFeedId(int feedId) async {
    // Authorization headers
    Map<String, String> headers = headersForAuth();
    final Uri uri = Uri.parse('$baseUrl/podcasts/byfeedid?id=$feedId&pretty');

    final response = await httpClient.get(uri, headers: headers);

    if (response.statusCode == 200) {
      // Parse the JSON response if the server returns a 200 OK status code.
      final Map<String, dynamic> jsonFeed = json.decode(response.body);
      final feed = jsonFeed['feed'];
      // Convert the JSON feed to PodcastModel object: lookup by feed id returns only one podcast within "feed"
      final PodcastEntity podcast =
          PodcastModel.fromJson(feed).toPodcastEntity();
      // Merge the found podcasts with subscribed podcasts, giving precedence to subscribed ones.
      return podcast;
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception(
          'Failed to load podcast by feed id: Status code ${response.statusCode}');
    }
  }

  /// Retrieves the list of subscribed podcasts.
  @override
  Future<List<PodcastEntity>> getSubscribedPodcasts() async {
    List<PodcastEntity> podcasts = podcastBox.getAll();
    return podcasts;
  }

  /// Merges the list of found podcasts with subscribed podcasts.
  ///
  /// If a podcast in [foundPodcasts] is also in [subscribedPodcasts],
  /// the subscribed version will replace the found version.
  Future<List<PodcastEntity>> _mergeWithSubscribedPodcasts(
      List<PodcastEntity> foundPodcasts) async {
    // get subscribed podcasts from db
    List<PodcastEntity> subscribedPodcasts = await getSubscribedPodcasts();

    if (subscribedPodcasts.isNotEmpty) {
      // Create a map to efficiently find subscribed podcasts.
      final Map<int, PodcastEntity> podcastMap = {};
      // Add found podcasts to the map.
      for (PodcastEntity fPodcast in foundPodcasts) {
        podcastMap[fPodcast.pId] = fPodcast;
      }
      // Replace found podcasts with subscribed podcasts if they exist.
      for (PodcastEntity sPodcast in subscribedPodcasts) {
        // Replace found podcasts with subscribed podcasts
        if (podcastMap.containsKey(sPodcast.pId)) {
          podcastMap[sPodcast.pId] = sPodcast;
        }
      }
      return podcastMap.values.toList();
    } else {
      return foundPodcasts;
    }
  }

  /// Encodes the keyword for use in a URL.
  String _encodeKeywordForUrl(String keyword) {
    return keyword.trim().replaceAll(' ', '+');
  }
}
