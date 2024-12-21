import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:podcast/application/is_loading/is_loading_cubit.dart';
import 'package:podcast/domain/entities/podcast_entity.dart';

import '../../../domain/repositories/podcast_repository.dart';
import '../../../injection.dart';
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
  List<PodcastEntity> results = [];

  void handleOnPressed(IsLoadingCubit isLoadingCubit, BuildContext context) async {
    if (_textEditingController.text.isNotEmpty) {
      FocusScope.of(context).unfocus();

      //Setting isLoading true to show the loader
      isLoadingCubit.setIsLoading(true);

      results = await sl<PodcastRepository>()
          .fetchPodcastsByKeywords(_textEditingController.text);

      final String keyword = _textEditingController.text;

      _textEditingController.clear();

      isLoadingCubit.setIsLoading(false);

      if (results.isEmpty) {
        setState(() {
          hintText = "No podcast was found";
        });
      } else {
        final String title =
            '${results.length} podcasts for "$keyword"';
        if (context.mounted) {
          Navigator.push(
            context,
            SlideRightRoute(
              page: PodcastResultsPage(
                results: results,
                title: title,
              ),
            ),
          );
        }
      }
    } else {
      setState(() {
        hintText = "Please enter a keyword";
      });
    }
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    IsLoadingCubit isLoadingCubit = BlocProvider.of<IsLoadingCubit>(context);
    return TextField(
      controller: _textEditingController,
      onTapOutside: (_) {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      onTap: () {
        hintText = "Search";
      },
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        hintText: hintText,
        suffixIcon: IconButton(
          icon: const Icon(Icons.search),
          onPressed: () => handleOnPressed(isLoadingCubit, context),
        ),
      ),
      style: const TextStyle(
        color: Color(0xFF202531),
      ),
    );
  }
}
