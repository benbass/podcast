import 'package:flutter/material.dart';

class ElevatedButtonSubscribe extends StatelessWidget {
  final bool subscribed;
  const ElevatedButtonSubscribe({super.key, required this.subscribed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {},
      child: Text(subscribed ? "Unsubscribed" : "Subscribe"),
    );
  }
}
