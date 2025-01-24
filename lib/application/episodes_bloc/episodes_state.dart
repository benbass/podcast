part of 'episodes_bloc.dart';

@immutable
sealed class EpisodesState {}

final class EpisodesInitial extends EpisodesState {}

final class EpisodesFetchingState extends EpisodesState {}

final class EpisodesReceivedState extends EpisodesState {
  final List<EpisodeEntity> episodes;
  EpisodesReceivedState({
    required this.episodes,
  });
}
