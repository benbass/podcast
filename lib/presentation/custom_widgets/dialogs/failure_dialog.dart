import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../application/podcast_bloc/podcast_bloc.dart';

class FailureDialog extends StatelessWidget {
  final String message;

  const FailureDialog({super.key, required this.message,});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
          child: Container(
            color: Colors.black26,
          ),
        ),
        AlertDialog(
          elevation: 30,
          shadowColor: Colors.black,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 60,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
                child: Text(message),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                BlocProvider.of<PodcastBloc>(context).add(ToggleStateToSuccessAfterFailureEvent());
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ],
    );
  }
}
