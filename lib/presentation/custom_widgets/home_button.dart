import 'package:flutter/material.dart';
import 'package:podcast/presentation/custom_widgets/page_transition.dart';
import '../homepage/homepage.dart';

class MyHomeButton extends StatelessWidget {
  const MyHomeButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        Navigator.push(
          context,
          ScaleRoute(
            page: const HomePage(),
          ),
        );
      },
      icon: const Icon(Icons.home_rounded),
    );
  }
}
