import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../domain/entities/subscribed_podcast_entity.dart';
import '../../domain/usecases/subscribed_podcast_usecases.dart';
import '../../helpers/core/get_android_version.dart';

part 'subscribed_podcasts_event.dart';
part 'subscribed_podcasts_state.dart';

class SubscribedPodcastsBloc extends Bloc<SubscribedPodcastsEvent, SubscribedPodcastsState> {
  final SubscribedPodcastUseCases subscribedPodcastUseCases;
  SubscribedPodcastsBloc({
    required this.subscribedPodcastUseCases,
  }) : super(SubscribedPodcastsInitial()) {

    on<SubscribedPodcastsLoadingEvent>((event, emit) async {
      // Let's call this method and set the needed variable at the app start
      getAndroidVersion();

      emit(SubscribedPodcastsLoadingState());

      final List<SubscribedPodcastEntity> subscribedPodcasts =
      await subscribedPodcastUseCases.getSubscribedPodcasts();

      add(SubscribedPodcastsLoadedEvent(
        subscribedPodcasts: subscribedPodcasts,
      ));

    });

    on<SubscribedPodcastsLoadedEvent>((event, emit) async {
      emit(SubscribedPodcastsLoadedState(
        subscribedPodcasts: event.subscribedPodcasts,
      ));
    });

  }
}
