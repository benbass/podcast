import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../helpers/audio_download/audio_download_queue_manager.dart';
import '../../domain/queued_audio_download/queued_audio_download.dart';

class AudioDownloadQueuePage extends StatelessWidget {
  const AudioDownloadQueuePage({super.key});

  @override
  Widget build(BuildContext context) {
    var themeData = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Download Queue"),
      ),
      body: Consumer<AudioDownloadQueueManager>(
        builder: (context, audioDownloadQueueManager, child) {
          final items = audioDownloadQueueManager.downloadItems;
          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return Card(
                key: ValueKey(item.id),
                color: themeData.colorScheme.primaryContainer,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    side: item.status == DownloadStatus.downloading
                        ? BorderSide(
                            color: themeData.colorScheme.secondary,
                            width: 2.0,
                          )
                        : BorderSide.none),
                elevation: 5.0,
                shadowColor: Colors.black,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      ConstrainedBox(
                        constraints: BoxConstraints(
                            maxWidth:
                            MediaQuery.of(context).size.width * 0.8,
                            minWidth:
                            MediaQuery.of(context).size.width * 0.6),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.episode.title,
                              overflow: TextOverflow.ellipsis,
                              softWrap: true,
                              maxLines: 2,
                              style: themeData.textTheme.displayMedium,
                            ),
                            const SizedBox(
                              height: 8.0,
                            ),
                            Text(_getStatusText(item)),
                          ],
                        ),
                      ),
                      const Spacer(),
                      _buildActionButtons(context, item),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _getStatusText(QueuedAudioDownload item) {
    switch (item.status) {
      case DownloadStatus.none:
        return "";
      case DownloadStatus.pending:
        return "Pending...";
      case DownloadStatus.downloading:
        return "Downloading: ${(item.progress * 100).toStringAsFixed(0)}%";
      case DownloadStatus.completed:
        return "Completed";
      case DownloadStatus.cancelled:
        return "Cancelled";
      case DownloadStatus.failed:
        return "Failed";
    }
  }

  Widget _buildActionButtons(BuildContext context, QueuedAudioDownload item) {
    final downloadQueueManager =
        Provider.of<AudioDownloadQueueManager>(context, listen: false);

    if (item.status == DownloadStatus.pending ||
        item.status == DownloadStatus.downloading) {
      return IconButton(
        icon: Icon(
          Icons.cancel,
          color: Theme.of(context).colorScheme.primary,
          size: 30,
        ),
        onPressed: () {
          downloadQueueManager.cancelDownload(item.id);
        },
      );
    } else if (item.status == DownloadStatus.completed ||
        item.status == DownloadStatus.cancelled ||
        item.status == DownloadStatus.failed) {
      return IconButton(
        icon: Icon(
          Icons.delete,
          color: Theme.of(context).colorScheme.primary,
          size: 30,
        ),
        onPressed: () {
          // Remove the item from the queue
          downloadQueueManager.removeItem(item.id);
        },
      );
    }
    return const SizedBox.shrink();
  }
}
