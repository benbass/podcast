import 'package:objectbox/objectbox.dart';

@Entity()
class AppPlaylist {
  @Id(assignable: true) // we have only 1 playlist to which we manually assign id = 1 (globalPlaylistId)
  int id;

  List<int> episodeIds;
  int? currentPlayingIndex;
  bool autoPlayEnabled;

  AppPlaylist({
    required this.id,
    required this.episodeIds,
    this.currentPlayingIndex,
    this.autoPlayEnabled = false,
  });

  AppPlaylist copyWith({
    List<int>? episodeIds,
    int? currentPlayingIndex,
    bool? autoPlayEnabled,
  }) {
    return AppPlaylist(
      id: id,
      episodeIds: episodeIds ?? this.episodeIds,
      currentPlayingIndex: currentPlayingIndex ?? this.currentPlayingIndex,
      autoPlayEnabled: autoPlayEnabled ?? this.autoPlayEnabled,
    );
  }
}