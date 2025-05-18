import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../application/podcast_bloc/podcast_bloc.dart';

class IconButtonWithPopupText extends StatefulWidget {
  const IconButtonWithPopupText({super.key});

  @override
  State<IconButtonWithPopupText> createState() =>
      _IconButtonWithPopupTextState();
}

class _IconButtonWithPopupTextState extends State<IconButtonWithPopupText> {
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();
  final TextEditingController _textController = TextEditingController();

  void _showTextOverlay() {
    _removeOverlay();

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: MediaQuery.of(context).size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: const Offset(-30, -80),
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
                          BlocProvider.of<PodcastBloc>(context).add(
                              const ToggleEpisodesFilterStatusEvent(
                                filterStatus: "all",
                                filterText: "",
                              ),
                          );
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
                      BlocProvider.of<PodcastBloc>(context).add(
                        ToggleEpisodesFilterStatusEvent(
                          filterStatus: "filterByText",
                          filterText: text,
                        ),
                      );
                    },
                    onChanged: (text) {
                      BlocProvider.of<PodcastBloc>(context).add(
                        ToggleEpisodesFilterStatusEvent(
                          filterStatus: "filterByText",
                          filterText: text,
                        ),
                      );
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
      child: CompositedTransformTarget(
        link: _layerLink,
        child: BlocBuilder<PodcastBloc, PodcastState>(
          builder: (context, state) {
            return IconButton(
              icon: Icon(
                state.filterText.isNotEmpty
                    ? Icons.filter_list_off_rounded
                    : Icons.search_rounded,
                size: 30,
              ),
              onPressed: state.filterText.isNotEmpty
                  ? () {
                      _textController.clear();
                      BlocProvider.of<PodcastBloc>(context).add(
                        const ToggleEpisodesFilterStatusEvent(
                          filterStatus: "all",
                          filterText: "",
                        ),
                      );
                    }
                  : () {
                      if (_overlayEntry == null) {
                        _showTextOverlay();
                      } else {
                        _removeOverlay();
                      }
                    },
            );
          },
        ),
      ),
    );
  }
}
