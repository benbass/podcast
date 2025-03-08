import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../application/podcast_bloc/podcast_bloc.dart';
import '../../custom_widgets/page_transition.dart';
import '../podcasts_search_page.dart';

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
      ScaleRoute(
        page: const PodcastsSearchPage(),
      ),
    );
  }

  Future<void> _performSearch(BuildContext context) async {
    if (_textEditingController.text.isNotEmpty) {
      FocusScope.of(context).unfocus();

      BlocProvider.of<PodcastBloc>(context)
          .add(SearchPodcastsByKeywordProcessingEvent(
          keyword: _textEditingController.text));

      //_textEditingController.clear();
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
    return BlocBuilder<PodcastBloc, PodcastState>(
      builder: (context, state) {
        return TextField(
          controller: _textEditingController,
          onTapOutside: (_) {
            FocusManager.instance.primaryFocus?.unfocus();
          },
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            hintText: state.keyword ?? hintText,
            suffixIcon: IconButton(
              icon: const Icon(Icons.search),
              onPressed: () => _performSearch(context),
            ),
          ),
          style: const TextStyle(
            color: Color(0xFF202531),
          ),
        );
      },
    );
  }
}
