import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../application/playback_cubit/playback_cubit.dart';
import '../../../application/user_playlist/user_playlist_cubit/user_playlist_cubit.dart';
import '../../../core/globals.dart';
import '../../custom_widgets/effects/backdropfilter.dart';

class UserPlaylistPageAppBar {
  static AppBar buildPlaylistPageAppBar(BuildContext context, ThemeData themeData) {
    final themeData = Theme.of(context);
    return AppBar(
      title: const Text('Playlist'),
      actions: [
        // Autoplay Toggle Button
        BlocBuilder<UserPlaylistCubit, UserPlaylistState>(
          builder: (context, state) {
            if (state is UserPlaylistLoaded) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Autoplay ",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary),
                  ),
                  Switch(
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    padding: EdgeInsets.zero,
                    inactiveThumbColor: Colors.grey,
                    value: state.autoPlayEnabled,
                    onChanged: (value) {
                      // Update the persistent autoplay setting in the cubit
                      context
                          .read<UserPlaylistCubit>()
                          .updatePersistentSettings(value);
                      // Update the autoplay setting in the playback cubit if the current playlist is the user's playlist
                      final String? origin = context.read<PlaybackCubit>().state.origin;
                      if (origin == globalPlaylistId.toString()) {
                        context.read<PlaybackCubit>().updateAutoPlay(autoplayEnabled: value);
                      }
                    },
                  ),
                ],
              );
            }
            return const SizedBox.shrink();
          },
        ),

        PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'clear') {
              _showClearPlaylistConfirmationDialog(context);
            }
          },
          color: themeData.colorScheme.primaryContainer,
          elevation: 8.0,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            PopupMenuItem<String>(
              value: 'clear',
              child: Text(
                'Clear playlist',
                style: themeData.textTheme.bodyLarge,
              ),
            ),
            // ...
          ],
        ),
      ],
    );
  }

  static void _showClearPlaylistConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return Stack(
          children: [
            const BackdropFilterWidget(sigma: 4.0),
            AlertDialog(
              title: const Text('Clear Playlist?'),
              content: const Text(
                  'Do you really want to remove all episodes from the playlist?'),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                  },
                ),
                TextButton(
                  child: const Text('Clear'),
                  onPressed: () {
                    context.read<UserPlaylistCubit>().clearPlaylist();
                    Navigator.of(dialogContext).pop();
                  },
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}


