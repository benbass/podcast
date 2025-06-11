part of 'podcast_settings_cubit.dart';

@immutable
abstract class PodcastSettingsState {}

class PodcastSettingsInitial extends PodcastSettingsState {}

class PodcastSettingsLoading extends PodcastSettingsState {}

class PodcastSettingsLoaded extends PodcastSettingsState {
  final PodcastFilterSettingsEntity settings;
  final PodcastEntity podcast;

  PodcastSettingsLoaded(this.settings, this.podcast);
}

class PodcastSettingsError extends PodcastSettingsState {
  final String message;
  PodcastSettingsError(this.message);
}
