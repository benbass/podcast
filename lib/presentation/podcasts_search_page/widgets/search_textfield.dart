import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:podcast/presentation/custom_widgets/failure_dialog.dart';

import '../../../application/podcast_bloc/podcast_bloc.dart';
import '../../../application/textfield_cubit/text_field_cubit.dart';
import '../../../helpers/core/connectivity_manager.dart';
import '../../../injection.dart';

class SearchTextField extends StatelessWidget {
  const SearchTextField({super.key});

  @override
  Widget build(BuildContext context) {

    String hintText = "Search";

    Future<void> performSearch(BuildContext context) async {
      if (context.read<TextFieldCubit>().state != null && context.read<TextFieldCubit>().state!.isNotEmpty) {
        FocusScope.of(context).unfocus();
        final String connectionType =
        await getIt<ConnectivityManager>().getConnectionTypeAsString();
        if (connectionType != 'none' && context.mounted) {
          BlocProvider.of<PodcastBloc>(context).add(
              GetRemotePodcastsByKeywordEvent(
                  keyword: context.read<TextFieldCubit>().state!));
        } else {
          if (context.mounted) {
            showDialog(
                context: context,
                builder: (context) =>
                const FailureDialog(message: "No internet connection!"));
          }
        }
      } else {
        if (context.mounted) {
          showDialog(
              context: context,
              builder: (context) =>
              const FailureDialog(message: "Please enter a keyword"));
        }
      }
    }

    return BlocBuilder<TextFieldCubit, String?>(
      builder: (context, state) {
        return TextField(
          onTapOutside: (_) {
            FocusManager.instance.primaryFocus?.unfocus();
          },
          onChanged: (value) => BlocProvider.of<TextFieldCubit>(context).setKeyword(value),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            hintText: state ?? hintText,
            suffixIcon: IconButton(
              icon: const Icon(Icons.search),
              onPressed: () => performSearch(context),
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
