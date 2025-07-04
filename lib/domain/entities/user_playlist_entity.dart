import 'package:objectbox/objectbox.dart';

@Entity()
class UserPlaylistEntity {
  @Id(assignable: true) // we have only 1 playlist to which we manually assign id = 1 (globalPlaylistId)
  int id;

  List<int> episodeIds;
  bool autoPlayEnabled;

  UserPlaylistEntity({
    required this.id,
    required this.episodeIds,
    this.autoPlayEnabled = false,
  });

  UserPlaylistEntity copyWith({
    List<int>? episodeIds,
    bool? autoPlayEnabled,
  }) {
    return UserPlaylistEntity(
      id: id,
      episodeIds: episodeIds ?? this.episodeIds,
      autoPlayEnabled: autoPlayEnabled ?? this.autoPlayEnabled,
    );
  }
}