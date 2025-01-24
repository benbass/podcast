import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../domain/entities/episode_entity.dart';
import '../../domain/usecases/episode_usecases.dart';

part 'episodes_event.dart';
part 'episodes_state.dart';

class EpisodesBloc extends Bloc<EpisodesEvent, EpisodesState> {
  final EpisodeUseCases episodeUseCases;

  StreamSubscription<List<EpisodeEntity>>? _streamSubscription;

  EpisodesBloc({required this.episodeUseCases}) : super(EpisodesInitial()) {
    on<EpisodesFetchingEvent>((event, emit) async {
      emit(EpisodesFetchingState());
      await _streamSubscription?.cancel();
      _streamSubscription = episodeUseCases
          .fetchEpisodes(event.id)
          .listen((episodes) => add(EpisodesReceivedEvent(episodes: episodes)));
    });

    on<EpisodesReceivedEvent>((event, emit) {
      emit(EpisodesReceivedState(episodes: event.episodes));
    });
  }

  @override
  Future<void> close() async {
    await _streamSubscription?.cancel();
    return super.close();
  }
}
