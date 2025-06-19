import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../application/podcast_settings_cubit/podcast_settings_cubit.dart';
import '../../../domain/entities/podcast_filter_settings_entity.dart';

class DropdownFilterMenu extends StatelessWidget {
  const DropdownFilterMenu({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PodcastSettingsCubit,
        PodcastSettingsState>(
        builder: (context, settingsState) {
          if (settingsState
          is PodcastSettingsLoaded) {
            final PodcastFilterSettingsEntity
            currentFilterSettings =
                settingsState.settings;
            String? dropdownValue;
            if (currentFilterSettings.showOnlyRead) {
              dropdownValue = 'Read';
            } else if (currentFilterSettings
                .showOnlyUnfinished) {
              dropdownValue = 'Unfinished';
            } else if (currentFilterSettings
                .showOnlyFavorites) {
              dropdownValue = 'Favorites';
            } else if (currentFilterSettings
                .showOnlyDownloaded) {
              dropdownValue = 'Downloaded';
            } else {
              if (!currentFilterSettings
                  .showOnlyRead &&
                  !currentFilterSettings
                      .showOnlyUnfinished &&
                  !currentFilterSettings
                      .showOnlyFavorites &&
                  !currentFilterSettings
                      .showOnlyDownloaded) {
                dropdownValue = 'All';
              } else {
                dropdownValue = null;
              }
            }
            return DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                icon: const Padding(
                  padding: EdgeInsets.only(left: 8.0),
                  child: Icon(Icons.filter_list_rounded),
                ),
                iconEnabledColor:
                const Color(0xFFF28F3B),
                dropdownColor:
                const Color(0xFF202531),
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge,
                borderRadius:
                BorderRadius.circular(10),
                alignment: Alignment.center,
                value: dropdownValue,
                hint: Text("All",
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge),
                isDense: true,
                padding: const EdgeInsets.symmetric(horizontal: 14.0),
                onChanged: (String? newValue) {
                  if (newValue == 'All') {
                    context
                        .read<PodcastSettingsCubit>()
                        .updateUiFilterSettings(
                      showOnlyRead: false,
                      showOnlyUnfinished: false,
                      showOnlyFavorites: false,
                      showOnlyDownloaded: false,
                    );
                  }
                  if (newValue == 'Read') {
                    context
                        .read<PodcastSettingsCubit>()
                        .updateUiFilterSettings(
                      filterRead: false,
                      showOnlyRead: true,
                      showOnlyUnfinished: false,
                      showOnlyFavorites: false,
                      showOnlyDownloaded: false,
                    );
                  }
                  if (newValue == 'Unfinished') {
                    context
                        .read<PodcastSettingsCubit>()
                        .updateUiFilterSettings(
                      showOnlyRead: false,
                      showOnlyUnfinished: true,
                      showOnlyFavorites: false,
                      showOnlyDownloaded: false,
                    );
                  }
                  if (newValue == 'Favorites') {
                    context
                        .read<PodcastSettingsCubit>()
                        .updateUiFilterSettings(
                      showOnlyRead: false,
                      showOnlyUnfinished: false,
                      showOnlyFavorites: true,
                      showOnlyDownloaded: false,
                    );
                  }
                  if (newValue == 'Downloaded') {
                    context
                        .read<PodcastSettingsCubit>()
                        .updateUiFilterSettings(
                      showOnlyRead: false,
                      showOnlyUnfinished: false,
                      showOnlyFavorites: false,
                      showOnlyDownloaded: true,
                    );
                  }
                },
                items: const <DropdownMenuItem<
                    String>>[
                  DropdownMenuItem<String>(
                    value: 'All',
                    alignment: AlignmentDirectional.center,
                    child: Text('All'),
                  ),
                  DropdownMenuItem<String>(
                    value: 'Read',
                    alignment: AlignmentDirectional.center,
                    child: Text('Read'),
                  ),
                  DropdownMenuItem<String>(
                    value: 'Unfinished',
                    alignment: AlignmentDirectional.center,
                    child: Text('Unfinished'),
                  ),
                  DropdownMenuItem<String>(
                    value: 'Favorites',
                    alignment: AlignmentDirectional.center,
                    child: Text('Favorites'),
                  ),
                  DropdownMenuItem<String>(
                    value: 'Downloaded',
                    alignment: AlignmentDirectional.center,
                    child: Text('Downloaded'),
                  ),
                ],
              ),
            );
          } else {
            return const SizedBox();
          }
        });
  }
}