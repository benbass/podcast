import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:podcast/core/globals.dart';

import '../../domain/entities/podcast_entity.dart';
import '../../helpers/authorization/authorization.dart';
import '../models/podcast_model.dart';

abstract class PodcastDataSource {
  /// Fetches podcasts based on a keyword, considering subscribed podcasts.
  Future<List<PodcastEntity>> fetchPodcastsByKeyword(
      String keyword);
  /// Retrieves the list of subscribed podcasts.
  Future<List<PodcastEntity>?> getSubscribedPodcasts();
}

class PodcastDataSourceImpl implements PodcastDataSource {
  final http.Client httpClient;

  PodcastDataSourceImpl({required this.httpClient});

  /// Fetches podcasts based on a keyword, considering subscribed podcasts.
  @override
  Future<List<PodcastEntity>> fetchPodcastsByKeyword(
      String keyword) async {
    // Prepare keyword for url
    String encodedKeyword = _encodeKeywordForUrl(keyword);

    // Authorization headers
    Map<String, String> headers = headersForAuth();

    final Uri uri = Uri.parse('$baseUrl/search/byterm?q=$encodedKeyword&pretty&max=1000');

    final response = await httpClient.get(
        uri,
        headers: headers);

    if (response.statusCode == 200) {
      // Parse the JSON response if the server returns a 200 OK status code.
      final Map<String, dynamic> jsonFeed = json.decode(response.body);
      final List<dynamic> feeds = jsonFeed['feeds'];
      // Convert the JSON feeds to PodcastModel objects, then explicitly convert them to PodcastEntity objects.
      // Explicit conversion is necessary because the list of podcasts can change during the application's lifetime.
      // Mixing PodcastEntity and PodcastModel types would lead to inconsistencies.
      final List<PodcastEntity> foundPodcasts =
          feeds.map((feed) => PodcastModel.fromJson(feed).toPodcastEntity()).toList();
      // Merge the found podcasts with subscribed podcasts, giving precedence to subscribed ones.
      return _mergeWithSubscribedPodcasts(foundPodcasts);
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load podcasts: Status code ${response.statusCode}');
    }
  }

  /// Retrieves the list of subscribed podcasts.
  @override
  Future<List<PodcastEntity>> getSubscribedPodcasts() async {
    List<PodcastEntity> podcasts = podcastBox.getAll();
    return podcasts ;
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
      for (PodcastEntity podcast in foundPodcasts) {
        podcastMap[podcast.pId] = podcast;
      }
      // Replace found podcasts with subscribed podcasts if they exist.
      for (PodcastEntity podcast in subscribedPodcasts) {
        // Replace found podcasts with subscribed podcasts
        if (podcastMap.containsKey(podcast.pId)) {
          podcastMap[podcast.pId] = podcast;
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
