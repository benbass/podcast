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

        // Let's refresh the episodes at app start
        for (PodcastEntity podcast in subscribedPodcasts) {
          await podcastUseCases.refreshPodcastEpisodes(podcast);
        }

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
      if (!event.podcast.subscribed) {
        emit(state.copyWith(loading: true));
        try {
          if (event.podcast.episodes.isEmpty) {
            final PodcastEntity podcastWithEpisodes =
                await podcastUseCases.fillPodcastWithEpisodes(event.podcast);
            emit(state.copyWith(
              podcast: podcastWithEpisodes,
            ));
          } else {
            final PodcastEntity podcastWithEpisodes =
                await podcastUseCases.refreshPodcastEpisodes(state.podcast!);
            emit(state.copyWith(
              podcast: podcastWithEpisodes,
            ));
          }
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

    on<RefreshPodcastEpisodesProcessingEvent>((event, emit) async {
      emit(state.copyWith(loading: true));
      PodcastEntity podcast =
          await podcastUseCases.refreshPodcastEpisodes(state.podcast!);
      emit(state.copyWith(
        podcast: podcast,
      ));
      add(FetchEpisodesForPodcastSuccessEvent());
    });

    on<PodcastTappedEvent>((event, emit) async {
      emit(state.copyWith(podcast: event.podcast));
    });

    on<SubscribeToPodcastEvent>((event, emit) async {
      /// Check if podcast is already subscribed
      // key = podcast pId, value = 0  (we need only the key for the check)
      Map<int, int> podcastPIdMap = {};
      for (PodcastEntity podcast in state.subscribedPodcasts) {
        podcastPIdMap[podcast.pId] = 0;
      }
      if (podcastPIdMap.containsKey(state.podcast!.pId)) {
        // If key exists, podcast is already subscribed
        emit(PodcastState.error(
            message:
                'You already subscribed to the podcast: ${state.podcast!.title}'));
      } else {
        bool objectIsSaved =
            await podcastUseCases.subscribeToPodcast(state.podcast!);
        if (objectIsSaved) {
          // Saving to db was successful
          // We get the list of subscribed podcasts from db
          List<PodcastEntity> subscribedPodcasts =
              await podcastUseCases.getSubscribedPodcasts();
          // We emit the new states with last subscribed podcast from the list
          emit(state.copyWith(subscribedPodcasts: [
            ...state.subscribedPodcasts,
            subscribedPodcasts.last
          ], podcast: subscribedPodcasts.last));
          // We update the list from the query result, if any, so list item will be correctly displayed as subscribed
          add(PodcastsQueryResultUpdateEvent());
        } else {
          emit(PodcastState.error(message: 'Failed to subscribe to podcast.'));
        }
      }
    });

    on<UnSubscribeFromPodcastEvent>((event, emit) async {
      emit(state.copyWith(loading: true));
      try {
        // We want to keep this podcast with all its episodes in case user navigates back to the episode list
        PodcastEntity unsubscribedPodcast = state.podcast!.copyWith(subscribed: false)..episodes.addAll(state.podcast!.episodes);
        await podcastUseCases.unsubscribeFromPodcast(state.podcast!);
        List<PodcastEntity> subscribedPodcasts = state.subscribedPodcasts;
        subscribedPodcasts
            .removeWhere((element) => element.pId == state.podcast!.pId);
        emit(state.copyWith(
          subscribedPodcasts: subscribedPodcasts,
          podcast: unsubscribedPodcast,
          loading: false,
        ));
        add(PodcastsQueryResultUpdateEvent());
      } catch (e) {
        emit(PodcastState.error(
            message:
                'Failed to unsubscribe from podcast: ${state.podcast!.title}'));
      }
    });

    on<PodcastsQueryResultUpdateEvent>((event, emit) async {
      List<PodcastEntity> podcastsQueryResult = state.podcastsQueryResult;

      // Replace object in query result, only if object is in query result
      Future<List<PodcastEntity>> updatedQueryResult() async {
        if (podcastsQueryResult.isNotEmpty) {
          // Create a map to store the API podcastIndex ids (pId) as keys
          Map<int, int> map = {};
          for (PodcastEntity podcast in podcastsQueryResult) {
            map[podcast.pId] = 0;
          }
          // Check if object is in map
          if (map.containsKey(state.podcast!.pId)) {
            // find index of object in query result
            final int index = podcastsQueryResult
                .indexWhere((element) => element.pId == state.podcast!.pId);

            // Remove old object from query result
            podcastsQueryResult.removeAt(index);
            // Insert new object in query result
            // the state of the new object (subscribed or not) was already set in the SubscribeToPodcastEvent or UnSubscribeFromPodcastEvent
            podcastsQueryResult.insert(index, state.podcast!);
          }
        }
        return podcastsQueryResult;
      }

      await updatedQueryResult();
    });

    on<ToggleUnreadEpisodesVisibilityEvent>((event, emit) async {
        emit(state.copyWith(areReadEpisodesVisible: event.areReadEpisodesVisible));
    });
  }
}
