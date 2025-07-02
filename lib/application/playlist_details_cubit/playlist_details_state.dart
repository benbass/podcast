part of 'playlist_details_cubit.dart';

@immutable
sealed class PlaylistDetailsState {}

final class PlaylistDetailsInitial extends PlaylistDetailsState {}

final class PlaylistDetailsLoading extends PlaylistDetailsState {}

final class PlaylistDetailsLoaded extends PlaylistDetailsState {
  final List<EpisodeEntity> playlist;
  final bool autoPlayEnabled;
  PlaylistDetailsLoaded({
    required this.playlist,
    required this.autoPlayEnabled,
  });
}

final class PlaylistDetailsInfo extends PlaylistDetailsState {
  final String message;
  PlaylistDetailsInfo(this.message);
}

final class PlaylistDetailsError extends PlaylistDetailsState {
  final String message;
  PlaylistDetailsError(this.message);
}
