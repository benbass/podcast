import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:podcast/domain/entities/podcast_entity.dart';
import 'package:podcast/domain/usecases/podcast_usecases.dart';

import '../../helpers/core/get_android_version.dart';

part 'podcasts_event.dart';
part 'podcasts_state.dart';

class PodcastsBloc extends Bloc<PodcastsEvent, PodcastsState> {
  final PodcastUseCases podcastUseCases;
  PodcastsBloc({
    required this.podcastUseCases,
  }) : super(PodcastsInitial()) {
    on<SubscribedPodcastsLoadingEvent>((event, emit) async {
      // Let's call this method and set the needed variable at the app start
      getAndroidVersion();

      emit(SubscribedPodcastsLoadingState());

      /// TODO: implement use case for getting podcasts from local database
      final List subscribedPodcasts =
          await podcastUseCases.getSubscribedPodcasts();
      add(SubscribedPodcastsLoadedEvent(
        subscribedPodcasts: subscribedPodcasts,
      ));
    });

    on<SubscribedPodcastsLoadedEvent>((event, emit) async {
      emit(SubscribedPodcastsLoadedState(
        subscribedPodcasts: event.subscribedPodcasts,
      ));
    });

    on<FindPodcastsPressedEvent>((event, emit) async {
      emit(PodcastsFetchingState());
      final List<PodcastEntity> podcasts =
          await podcastUseCases.fetchPodcasts(event.keyword);
      add(PodcastsReceivedEvent(
        keyword: event.keyword,
        podcasts: podcasts,
      ));
    });

    on<PodcastsReceivedEvent>((event, emit) async {
      emit(PodcastsReceivedState(
        keyword: event.keyword,
        podcasts: event.podcasts,
      ));
    });
  }
}
