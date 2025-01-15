part of 'podcasts_bloc.dart';

@immutable
sealed class PodcastsState {}

final class PodcastsInitial extends PodcastsState {}

final class PodcastsFetchingState extends PodcastsState {}

final class PodcastsReceivedState extends PodcastsState {
  final String keyword;
  final List<PodcastEntity> podcasts;

  PodcastsReceivedState({
    required this.keyword,
    required this.podcasts,
  });
}
