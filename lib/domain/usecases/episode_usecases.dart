import 'package:podcast/domain/repositories/episode_repository.dart';

import '../entities/episode_entity.dart';

class   EpisodeUseCases{
  final EpisodeRepository episodeRepository;

  EpisodeUseCases({required this.episodeRepository});

  Stream<List<EpisodeEntity>> fetchEpisodes(int id){
    return episodeRepository.fetchEpisodesByFeedId(id);
  }
}