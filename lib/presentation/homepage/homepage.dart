import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:podcast/presentation/homepage/widgets/search_textfield.dart';

import '../../application/is_loading/is_loading_cubit.dart';
import '../../helpers/core/get_android_version.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  // We will replace this with list of subscribed podcasts from database when implemented
  List fakeEmptyList = [];

  @override
  void initState() {
    getAndroidVersion();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Podcasts"),
      ),
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 10),
                child: SearchTextField(),
              ),
            ),
            fakeEmptyList.isEmpty
                ? const SliverToBoxAdapter(
                    child: Column(
                      children: [
                        Icon(
                          Icons.arrow_upward_rounded,
                          size: 50,
                        ),
                        Text("Quite empty here!"),
                        Text("Search and follow podcasts."),
                      ],
                    ),
                  )
                : const SliverToBoxAdapter(child: SizedBox.shrink()),
            // Loader while we fetch podcasts
            BlocBuilder<IsLoadingCubit, bool>(builder: (context, state) {
              if (state == true) {
                return const SliverPadding(
                  padding: EdgeInsets.only(top: 100.0),
                  sliver: SliverToBoxAdapter(
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                );
              } else {
                return const SliverToBoxAdapter(
                  child: SizedBox.shrink(),
                );
              }
            })
          ],
        ),
      ),
    );
  }
}
