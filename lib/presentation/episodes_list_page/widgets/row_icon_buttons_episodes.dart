import 'package:flutter/material.dart';

class RowIconButtonsEpisodes extends StatelessWidget {
  const RowIconButtonsEpisodes({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        IconButton(
          onPressed: () {
            // full text search
          },
          icon: const Icon(
            Icons.search_rounded,
            size: 30,
          ),
        ),
        IconButton(
          onPressed: () {
            // activate select on list items
          },
          icon: const Icon(
            Icons.check_rounded,
            size: 30,
          ),
        ),
        IconButton(
          onPressed: () {
            // make a query
          },
          icon: const Icon(
            Icons.refresh_rounded,
            size: 30,
          ),
        ),
      ],
    );
  }
}