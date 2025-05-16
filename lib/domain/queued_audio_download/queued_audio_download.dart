import 'package:uuid/uuid.dart';

import '../../helpers/audio_download/audio_download_service.dart';
import '../entities/episode_entity.dart';

/// This model class defines the state of a download in the queue.
class QueuedAudioDownload {
  final String id;
  final EpisodeEntity episode;
  double progress;
  DownloadStatus status;
  AudioDownloadService? downloadService; // Reference to the service, if active
  String? filePath; // Saved file path, if download completed

  QueuedAudioDownload({
    required this.episode,
    this.progress = 0.0,
    this.status = DownloadStatus.pending,
    this.downloadService,
    this.filePath,
    String? id,
  }) : id = id ??
            const Uuid()
                .v4(); // generate an id if not provided. If provided we prevent new id to be assigned when using copyWith!

  QueuedAudioDownload copyWith({
    double? progress,
    DownloadStatus? status,
    AudioDownloadService? downloadService,
    String? filePath,
    String? id,
  }) {
    return QueuedAudioDownload(
      episode: episode,
      progress: progress ?? this.progress,
      status: status ?? this.status,
      downloadService: downloadService ?? this.downloadService,
      filePath: filePath ?? this.filePath,
      id: id ?? this.id,
    );
  }
}

enum DownloadStatus {
  none,
  pending,
  downloading,
  completed,
  cancelled,
  failed,
}
