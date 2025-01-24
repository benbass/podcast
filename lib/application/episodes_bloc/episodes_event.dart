part of 'episodes_bloc.dart';

@immutable
sealed class EpisodesEvent {}

final class EpisodesFetchingEvent extends EpisodesEvent {
  final int id;

  EpisodesFetchingEvent({
    required this.id,
  });
}

final class EpisodesReceivedEvent extends EpisodesEvent {
  final List<EpisodeEntity> episodes;
  EpisodesReceivedEvent({
    required this.episodes,
  });
}
