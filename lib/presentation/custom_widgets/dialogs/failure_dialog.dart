import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../application/podcast_bloc/podcast_bloc.dart';
import '../effects/backdropfilter.dart';

class FailureDialog extends StatelessWidget {
  final String message;

  const FailureDialog({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const BackdropFilterWidget(sigma: 4.0),
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
                BlocProvider.of<PodcastBloc>(context)
                    .add(ToggleStateToSuccessAfterFailureEvent());
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ],
    );
  }
}
