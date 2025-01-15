import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../application/podcasts_bloc/podcasts_bloc.dart';
import '../../custom_widgets/page_transition.dart';
import '../../podcast_results_page/podcast_results_page.dart';

class SearchTextField extends StatefulWidget {
  const SearchTextField({super.key});

  @override
  State<SearchTextField> createState() => _SearchTextFieldState();
}

class _SearchTextFieldState extends State<SearchTextField> {
  final TextEditingController _textEditingController = TextEditingController();
  String hintText = "Search";

  void _navigateToResultsPage(BuildContext context) {
    Navigator.push(
      context,
      SlideRightRoute(
        page: const PodcastResultsPage(),
      ),
    );
  }

  Future<void> _performSearch(BuildContext context) async {
    if (_textEditingController.text.isNotEmpty) {
      FocusScope.of(context).unfocus();

      BlocProvider.of<PodcastsBloc>(context)
          .add(FindPodcastsPressedEvent(keyword: _textEditingController.text));

      _textEditingController.clear();
      _navigateToResultsPage(context);
    } else {
      hintText = "Please enter a keyword";
    }
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _textEditingController,
      onTapOutside: (_) {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        hintText: hintText,
        suffixIcon: IconButton(
          icon: const Icon(Icons.search),
          onPressed: () => _performSearch(context),
        ),
      ),
      style: const TextStyle(
        color: Color(0xFF202531),
      ),
    );
  }
}
