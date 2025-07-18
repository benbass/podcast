import 'package:flutter/material.dart';
import 'package:podcast/domain/usecases/episode_usecases.dart';
import 'package:podcast/presentation/custom_widgets/effects/backdropfilter.dart';

import '../../domain/entities/episode_entity.dart';
import '../../domain/queued_audio_download/queued_audio_download.dart';
import '../../helpers/audio_download/audio_download_queue_manager.dart';
import '../../helpers/audio_download/audio_file_utility.dart';
import '../../helpers/database/episode_action_helper.dart';
import '../../injection.dart';
import 'action_feedback/action_feedback.dart';

class EpisodeActionsRow extends StatefulWidget {
  final EpisodeEntity episode;
  const EpisodeActionsRow({
    super.key,
    required this.episode,
  });

  @override
  State<EpisodeActionsRow> createState() => _EpisodeActionsRowState();
}

class _EpisodeActionsRowState extends State<EpisodeActionsRow> {
  late AudioDownloadQueueManager _queueManager;
  QueuedAudioDownload? _currentDownloadItemForThisEpisode;

  @override
  void initState() {
    super.initState();
    _queueManager = AudioDownloadQueueManager();
    _queueManager.addListener(_onDownloadQueueChanged);
    _updateCurrentDownloadItem();
  }

  @override
  void dispose() {
    _queueManager.removeListener(_onDownloadQueueChanged);
    super.dispose();
  }

  void _onDownloadQueueChanged() {
    if (mounted) {
      setState(() {
        _updateCurrentDownloadItem();
      });
    }
  }

  void _updateCurrentDownloadItem() {
    final items = _queueManager.downloadItems;
    final index =
        items.indexWhere((item) => item.episode.id == widget.episode.id);
    if (index != -1) {
      _currentDownloadItemForThisEpisode = items[index];
    } else {
      _currentDownloadItemForThisEpisode = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDownloadingOrPending = false;
    DownloadStatus currentStatus = DownloadStatus.none;
    double currentDownloadProgress = 0.0;

    if (_currentDownloadItemForThisEpisode != null) {
      currentStatus = _currentDownloadItemForThisEpisode!.status;
      currentDownloadProgress = _currentDownloadItemForThisEpisode!.progress;
      if (currentStatus == DownloadStatus.downloading ||
          currentStatus == DownloadStatus.pending) {
        isDownloadingOrPending = true;
      }
    }

    return StreamBuilder<EpisodeEntity?>(
        stream: getIt<EpisodeUseCases>()
            .getEpisodeStream(episodeId: widget.episode.id),
        initialData: widget.episode,
        builder: (context, snapshot) {
          bool isRead = snapshot.data?.read ?? widget.episode.read;
          bool isFavorite = snapshot.data?.favorite ?? widget.episode.favorite;
          String? filePath = snapshot.data?.filePath;
          return SizedBox(
            width: MediaQuery.of(context).size.width - 140,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Spacer(flex: 3),
                Icon(
                  isRead ? Icons.check_rounded : null,
                  size: 30.0,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    EpisodeActionHelper.performActionOnEpisode(
                        widget.episode, "favorite", isFavorite);
                  },
                  onTapDown: (TapDownDetails details) => ActionFeedback.show(
                      context,
                      icon: Icons.star_rounded,
                      tapDownPosition: details.globalPosition),
                  child: Icon(
                    isFavorite ? Icons.star_rounded : Icons.star_border_rounded,
                    size: 30.0,
                    color: isFavorite
                        ? Theme.of(context).colorScheme.primary
                        : Colors.white12,
                  ),
                ),
                const Spacer(),
                if (isDownloadingOrPending)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: _buildProgressIndicator(
                        context, currentStatus, currentDownloadProgress),
                  )
                else
                  IconButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return Stack(
                            children: [
                              const BackdropFilterWidget(sigma: 4.0),
                              AlertDialog(
                                title: Text(
                                  filePath != null
                                      ? "Delete the downloaded file?"
                                      : "Download the episode?",
                                ),
                                content: Text(filePath != null
                                    ? "The file will be deleted from your device."
                                    : "This will download the file to your device."),
                                actions: [
                                  TextButton(
                                    onPressed: () => {
                                      Navigator.pop(context),
                                    },
                                    child: const Text(
                                      "Cancel",
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      AudioFileUtility.handleDownloadOnPressed(
                                          widget.episode);
                                    },
                                    child: Text(
                                      filePath != null ? "Delete" : "Download",
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          );
                        },
                      );
                    },
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                    icon: Icon(
                      filePath != null
                          ? Icons.delete_rounded
                          : Icons.save_alt_rounded,
                      size: 30.0,
                      color: filePath != null
                          ? Theme.of(context).colorScheme.primary
                          : Colors.white12,
                    ),
                  ),
              ],
            ),
          );
        });
  }

  Widget _buildProgressIndicator(
      BuildContext context, DownloadStatus status, double progress) {
    const double indicatorSize = 24.0;

    switch (status) {
      case DownloadStatus.pending:
        return const SizedBox(
          width: indicatorSize,
          height: indicatorSize,
          child: CircularProgressIndicator(
            strokeWidth: 2.0,
            value: null, // Indeterminate
          ),
        );
      case DownloadStatus.downloading:
        return SizedBox(
          width: indicatorSize,
          height: indicatorSize,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                value: progress,
                strokeWidth: 3.0,
                backgroundColor: Theme.of(context).colorScheme.secondary,
                valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.onPrimary),
              ),
              Text('${(progress * 100).toInt()}%',
                  style: const TextStyle(fontSize: 8)),
            ],
          ),
        );
      default:
        return const SizedBox(
          width: indicatorSize,
          height: indicatorSize,
          child: Icon(
            Icons.help_outline,
            size: indicatorSize,
          ),
        );
    }
  }
}
