import 'package:podcast/core/globals.dart';
import 'package:podcast/domain/repositories/episode_repository.dart';

import '../../objectbox.g.dart';
import '../entities/episode_entity.dart';

class EpisodeUseCases {
  final EpisodeRepository episodeRepository;

  EpisodeUseCases({required this.episodeRepository});

  // Depending on parameters, we either return local or remote data,
  // and for local data we may filter episodes based on read status
  Stream<List<EpisodeEntity>> getEpisodes({
    required bool subscribed,
    required int feedId,
    required String podcastTitle,
    required String filterStatus,
    required bool refresh,
    String? filterText,
  }) {
    return episodeRepository.getEpisodes(
      subscribed: subscribed,
      feedId: feedId,
      podcastTitle: podcastTitle,
      filterStatus: filterStatus,
      refresh: refresh,
      filterText: filterText,
    );
  }

  Stream<bool> getFavoriteStatus({required int episodeId}) {
    final queryBuilder = episodeBox.query(EpisodeEntity_.id.equals(episodeId));
    return queryBuilder.watch(triggerImmediately: true).map((query) {
      final results = query.find();
      if (results.isNotEmpty) {
        return results.first.favorite;
      } else {
        return false;
      }
    });
  }

  Stream<bool> getReadStatus({required int episodeId}) {
    final queryBuilder = episodeBox.query(EpisodeEntity_.id.equals(episodeId));
    return queryBuilder.watch(triggerImmediately: true).map((query) {
      final results = query.find();
      if (results.isNotEmpty) {
        return results.first.read;
      } else {
        return false;
      }
    });
  }

  Stream<String?> getDownloadStatus({required int episodeId}) {
    final queryBuilder = episodeBox.query(EpisodeEntity_.id.equals(episodeId));
    return queryBuilder.watch(triggerImmediately: true).map((query) {
      final results = query.find();
      if (results.isNotEmpty) {
        return results.first.filePath;
      } else {
        return null;
      }
    });
  }

  Stream<int> unreadLocalEpisodesCount({required int feedId}) {
    return episodeRepository.unreadLocalEpisodesCount(feedId: feedId);
  }
}
