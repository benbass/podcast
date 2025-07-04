import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../application/podcast/podcast_settings_cubit/podcast_settings_cubit.dart';

class ToggleReadVisibility extends StatelessWidget {
  const ToggleReadVisibility({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PodcastSettingsCubit, PodcastSettingsState>(
        builder: (context, settingsState) {
      if (settingsState is PodcastSettingsLoaded) {
        return IconButton(
          onPressed: () {
            context.read<PodcastSettingsCubit>().updateUiFilterSettings(
                  filterRead: settingsState.settings.filterRead ? false : true,
                  showOnlyRead: false,
                );
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(
                    "Read episodes are ${settingsState.settings.filterRead ? "not hidden" : "hidden"}"),
                duration: const Duration(milliseconds: 1500)));
          },
          icon: Icon(
            settingsState.settings.filterRead
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            size: 30,
          ),
        );
      } else {
        return const SizedBox();
      }
    });
  }
}
