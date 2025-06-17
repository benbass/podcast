import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../application/podcast_bloc/podcast_bloc.dart';
import '../../../application/podcast_settings_cubit/podcast_settings_cubit.dart';

class IconButtonWithPopupText extends StatefulWidget {
  const IconButtonWithPopupText({super.key});

  @override
  State<IconButtonWithPopupText> createState() =>
      _IconButtonWithPopupTextState();
}

class _IconButtonWithPopupTextState extends State<IconButtonWithPopupText> {
  OverlayEntry? _overlayEntry;
  final TextEditingController _textController = TextEditingController();

  void _showTextOverlay() {
    _removeOverlay();

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: MediaQuery.of(context).size.width,
        child: SafeArea(
          child: Material(
            color: Theme.of(context).colorScheme.primaryContainer,
            elevation: 4.0,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _textController,
                    decoration: InputDecoration(
                      hintText: 'Search in titles and descriptions...',
                      hintStyle: const TextStyle(color: Colors.grey),
                      suffixIcon: IconButton(
                        onPressed: () {
                          _textController.clear();
                          context
                              .read<PodcastSettingsCubit>()
                              .updateUiFilterSettings(
                                  filterByText: false, transientSearchText: "");
                        },
                        icon: Icon(
                          Icons.cancel,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(8)),
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                      border: OutlineInputBorder(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(8)),
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(8)),
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                    ),
                    onSubmitted: (text) {
                      context
                          .read<PodcastSettingsCubit>()
                          .updateUiFilterSettings(
                              filterByText: true, transientSearchText: text);
                    },
                    onChanged: (text) {
                      context
                          .read<PodcastSettingsCubit>()
                          .updateUiFilterSettings(
                              filterByText: true, transientSearchText: text);
                    },
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: _removeOverlay,
                    child: const Text("Close"),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  void dispose() {
    _textController.dispose();
    _removeOverlay();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: BlocBuilder<PodcastBloc, PodcastState>(
        builder: (context, state) {
          final settingState = context.watch<PodcastSettingsCubit>().state;
          if (settingState is PodcastSettingsLoaded) {
            final settings = settingState.settings;
            return IconButton(
              icon: Icon(
                settings.transientSearchText != null &&
                        settings.transientSearchText!.isNotEmpty
                    ? Icons.filter_list_off_rounded
                    : Icons.search_rounded,
                size: 30,
              ),
              onPressed: settings.transientSearchText != null &&
                      settings.transientSearchText!.isNotEmpty
                  ? () {
                      _textController.clear();
                      context
                          .read<PodcastSettingsCubit>()
                          .updateUiFilterSettings(
                              filterByText: false, transientSearchText: "");
                    }
                  : () {
                      if (_overlayEntry == null) {
                        _showTextOverlay();
                      } else {
                        _removeOverlay();
                      }
                    },
            );
          } else {
            return const SizedBox();
          }
        },
      ),
    );
  }
}
