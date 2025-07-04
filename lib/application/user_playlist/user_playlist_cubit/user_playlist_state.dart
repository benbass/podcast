part of 'user_playlist_cubit.dart';

@immutable
sealed class UserPlaylistState {}

final class UserPlaylistInitial extends UserPlaylistState {}

final class UserPlaylistLoading extends UserPlaylistState {}

final class UserPlaylistLoaded extends UserPlaylistState {
  final List<EpisodeEntity> userPlaylist;
  final bool autoPlayEnabled;
  UserPlaylistLoaded({
    required this.userPlaylist,
    required this.autoPlayEnabled,
  });
}

final class UserPlaylistMessage extends UserPlaylistState {
  final String message;
  UserPlaylistMessage(this.message);
}

final class UserPlaylistError extends UserPlaylistState {
  final String message;
  UserPlaylistError(this.message);
}
