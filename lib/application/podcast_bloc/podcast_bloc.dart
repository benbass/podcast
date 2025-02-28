import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:podcast/domain/entities/podcast_entity.dart';
import 'package:podcast/domain/usecases/podcast_usecases.dart';

part 'podcast_event.dart';
part 'podcast_state.dart';

class PodcastBloc extends Bloc<PodcastEvent, PodcastState> {
  final PodcastUseCases podcastUseCases;
  PodcastBloc({
    required this.podcastUseCases,
  }) : super(PodcastState.initial()) {
    on<SubscribedPodcastsLoadingEvent>((event, emit) async {
      emit(state.copyWith(loading: true));
      try {
        List<PodcastEntity> subscribedPodcasts =
            await podcastUseCases.getSubscribedPodcasts();

        emit(state.copyWith(
          subscribedPodcasts: subscribedPodcasts,
        ));
        add(SubscribedPodcastsLoadedEvent());
      } catch (e) {
        emit(PodcastState.error(
            message: 'Failed to load the podcasts from the database'));
      }
    });

    on<SubscribedPodcastsLoadedEvent>((event, emit) async {
      emit(state.copyWith(loading: false));
    });

    on<SearchPodcastsByKeywordProcessingEvent>((event, emit) async {
      emit(state.copyWith(loading: true, keyword: event.keyword));
      try {
        List<PodcastEntity> podcastsQueryResult =
            await podcastUseCases.fetchPodcasts(event.keyword);

        emit(state.copyWith(
          podcastsQueryResult: podcastsQueryResult,
        ));
        add(SearchPodcastsByKeywordSuccessEvent());
      } catch (e) {
        emit(PodcastState.error(
            message:
                'Failed to load podcasts from the server.\nThe server may be down.\nError: ${e.toString()}'));
      }
    });

    on<SearchPodcastsByKeywordSuccessEvent>((event, emit) async {
      emit(state.copyWith(loading: false));
    });

    on<FetchEpisodesForPodcastProcessingEvent>((event, emit) async {
      if(!event.podcast.subscribed){
        emit(state.copyWith(loading: true));
        try {
          final PodcastEntity podcastWithEpisodes =
          await podcastUseCases.fillPodcastWithEpisodes(event.podcast);
          emit(state.copyWith(
            podcast: podcastWithEpisodes,
          ));
          add(FetchEpisodesForPodcastSuccessEvent());
        } catch (e) {
          emit(PodcastState.error(
              message:
              'Failed to load episodes from the server.\nThe server may be down.\nError: ${e.toString()}'));
        }
      }
    });

    on<FetchEpisodesForPodcastSuccessEvent>((event, emit) async {
      emit(state.copyWith(loading: false));
    });

    on<PodcastTappedEvent>((event, emit) async {
      emit(state.copyWith(podcast: event.podcast));
    });

    on<SubscribeToPodcastEvent>((event, emit) async {
      emit(state.copyWith(podcast: event.podcast));

      /// Check if podcast is already subscribed
      // key = podcast pId, value = 0  (we need only the key for the check)
      Map<int, int> podcastPIdMap = {};
      for (PodcastEntity podcast in state.subscribedPodcasts) {
        podcastPIdMap[podcast.pId] = 0;
      }
      if (podcastPIdMap.containsKey(event.podcast.pId)) {
        // If key exists, podcast is already subscribed
        emit(PodcastState.error(
            message:
                'You already subscribed to the podcast: ${event.podcast.title}'));
      } else {
        var obj = await podcastUseCases.subscribeToPodcast(event.podcast);
        if (obj is PodcastEntity) {
          emit(state.copyWith(
              subscribedPodcasts: [...state.subscribedPodcasts, obj]));
          add(SubscriptionStateChangedEvent(podcast: obj));
        } else {
          emit(PodcastState.error(
              message: 'Failed to subscribe to podcast. Error: $obj'));
        }
      }
    });

    on<UnSubscribeFromPodcastEvent>((event, emit) async {
      PodcastEntity unsubscribedPodcast = event.podcast;
      emit(state.copyWith(podcast: unsubscribedPodcast));
      try {
        // Remove from db and get updated list of subscribed podcasts
        List<PodcastEntity> subscribedPodcasts =
            await podcastUseCases.unsubscribeFromPodcast(unsubscribedPodcast);
        // emit state
        emit(state.copyWith(
          subscribedPodcasts: subscribedPodcasts,
        ));

        add(SubscriptionStateChangedEvent(
            podcast: unsubscribedPodcast.copyWith(subscribed: false)));
      } catch (e) {
        emit(PodcastState.error(
            message:
                'Failed to unsubscribe from podcast: ${event.podcast.title}'));
      }
    });

    on<SubscriptionStateChangedEvent>((event, emit) async {
      List<PodcastEntity> podcastsQueryResult = state.podcastsQueryResult;

      // Replace object in query result, only if object is in query result
      Future<List<PodcastEntity>> updatedQueryResult() async {
        if (podcastsQueryResult.isNotEmpty) {
          // Create a map to store the API podcastIndex ids (pId)
          Map<int, int> map = {};
          for (PodcastEntity podcast in podcastsQueryResult) {
            map[podcast.pId] = 0;
          }
          // Check if object is in map
          if (map.containsKey(event.podcast.pId)) {
            // find index of object in query result
            final int index = podcastsQueryResult
                .indexWhere((element) => element.pId == event.podcast.pId);
            // Remove old object from query result
            podcastsQueryResult.removeAt(index);
            // Insert new object in query result
            podcastsQueryResult.insert(index, event.podcast);
          }
        }

        return podcastsQueryResult;
      }

      // Update query result
      List<PodcastEntity> updatedList = await updatedQueryResult();

      emit(state.copyWith(
        podcastsQueryResult: updatedList,
      ));
    });
  }
}
