import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../application/podcast_settings_cubit/podcast_settings_cubit.dart';

class PodcastSettingsDrawer extends StatefulWidget {
  const PodcastSettingsDrawer({
    super.key,
  });

  @override
  State<PodcastSettingsDrawer> createState() => _PodcastSettingsDrawerState();
}

class _PodcastSettingsDrawerState extends State<PodcastSettingsDrawer> {
  late bool _currentFilterExplicit;
  late bool _currentFilterTrailer;
  late bool _currentFilterBonus;
  late int? _currentMinDurationMinutes;
  late String? _podcastTitle;

  // For Slider
  static const double _minSliderValue = 0;
  static const double _maxSliderValue = 120;
  static final int _sliderDivisions =
      (_maxSliderValue - _minSliderValue).round();

  @override
  void initState() {
    super.initState();
    final cubitState = context.read<PodcastSettingsCubit>().state;
    if (cubitState is PodcastSettingsLoaded) {
      _currentFilterExplicit = cubitState.settings.filterExplicitEpisodes;
      _currentFilterTrailer = cubitState.settings.filterTrailerEpisodes;
      _currentFilterBonus = cubitState.settings.filterBonusEpisodes;
      _currentMinDurationMinutes =
          cubitState.settings.minEpisodeDurationMinutes;
      _podcastTitle = cubitState.podcast.title;
    } else {
      _currentFilterExplicit = false;
      _currentFilterTrailer = false;
      _currentFilterBonus = false;
      _currentMinDurationMinutes = null;
      _podcastTitle = "";
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    final cubitState = context.watch<PodcastSettingsCubit>().state;

    if (cubitState is PodcastSettingsLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (cubitState is PodcastSettingsError) {
      return Center(child: Text(cubitState.message,
      style: themeData.textTheme.displayLarge,));
    }

    double sliderUiValue =
        (_currentMinDurationMinutes ?? _minSliderValue).toDouble();
    if (sliderUiValue < _minSliderValue) sliderUiValue = _minSliderValue;
    if (sliderUiValue > _maxSliderValue) sliderUiValue = _maxSliderValue;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 100.0, horizontal: 20.0),
      child: Column(
        children: [
          Text(
            "Filter for $_podcastTitle",
            style: themeData.textTheme.displayLarge,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 20.0),
            child: Text("Note: These filters may not work if the podcast author doesn't provide this information or provides it incorrectly."),
          ),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Ignore explicit episodes"),
              Switch(
                value: _currentFilterExplicit,
                onChanged: (value) {
                  setState(() {
                    _currentFilterExplicit = value;
                    context
                        .read<PodcastSettingsCubit>()
                        .updatePersistentSettings(filterExplicitEpisodes: value);
                  });
                },
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Ignore trailer episodes"),
              Switch(
                value: _currentFilterTrailer,
                onChanged: (value) {
                  setState(() {
                    _currentFilterTrailer = value;
                    context
                        .read<PodcastSettingsCubit>()
                        .updatePersistentSettings(filterTrailerEpisodes: value);
                  });
                },
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Ignore bonus episodes"),
              Switch(
                value: _currentFilterBonus,
                onChanged: (value) {
                  setState(() {
                    _currentFilterBonus = value;
                    context
                        .read<PodcastSettingsCubit>()
                        .updatePersistentSettings(filterBonusEpisodes: value);
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          Divider(color: themeData.colorScheme.primary),
          const SizedBox(height: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 4.0, bottom: 0),
                child: Text(
                  "Ignore episodes shorter than:\n${sliderUiValue == _minSliderValue ? 'No limit' : '${sliderUiValue.round()} min.'}",
                ),
              ),
              Slider(
                  value: sliderUiValue,
                  min: _minSliderValue,
                  max: _maxSliderValue,
                  divisions: _sliderDivisions,
                  thumbColor: themeData.colorScheme.onPrimary,
                  label: sliderUiValue == _minSliderValue
                      ? 'No limit'
                      : '${sliderUiValue.round()} min.',
                  onChanged: (double value) {
                    setState(() {
                      _currentMinDurationMinutes = value.round();
                    });
                  },
                  onChangeEnd: (double value) {
                    context
                        .read<PodcastSettingsCubit>()
                        .updatePersistentSettings(minEpisodeDurationMinutes: value.round());
                  }),
            ],
          ),
          const SizedBox(height: 20),
          Divider(color: themeData.colorScheme.primary),
          const SizedBox(height: 120),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }
}
