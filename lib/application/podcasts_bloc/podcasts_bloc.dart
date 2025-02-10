import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:podcast/domain/entities/podcast_entity.dart';
import 'package:podcast/domain/usecases/podcast_usecases.dart';
import '../../domain/usecases/episode_usecases.dart';

part 'podcasts_event.dart';
part 'podcasts_state.dart';

class PodcastsBloc extends Bloc<PodcastsEvent, PodcastsState> {
  final PodcastUseCases podcastUseCases;
  final EpisodeUseCases episodeUseCases;
  PodcastsBloc({
    required this.podcastUseCases,
    required this.episodeUseCases,
  }) : super(PodcastsInitial()) {
    List<PodcastEntity> subscribedPodcasts = [];
    String queryTerm = '';
    List<PodcastEntity> podcastsQueryResult = [];

    /// LOCAL: GET SUBSCRIBED PODCASTS
    on<FetchSubscribedPodcastsEvent>((event, emit) async {
      emit(FetchingSubscribedPodcastsState());
      try {
        List<PodcastEntity>? podcasts =
            await podcastUseCases.getSubscribedPodcasts();
        if (podcasts != null) {
          subscribedPodcasts = podcasts;
        }
        emit(SubscribedPodcastsFetchSuccessState(podcasts: subscribedPodcasts));
      } catch (e) {
        emit(SubscribedPodcastsFetchErrorState(
            message: 'Failed to load the podcasts from the database'));
      }
    });

    ///

    /// REMOTE: FIND PODCASTS
    // podcasts by keyword: we get a list
    on<FetchPodcastsEvent>((event, emit) async {
      queryTerm = event.keyword;
      emit(PodcastsFetchingState());
      try {
        podcastsQueryResult =
            await podcastUseCases.fetchPodcasts(queryTerm, subscribedPodcasts);
        add(PodcastsFetchSuccessEvent(
          keyword: queryTerm,
          podcastsQueryResult: podcastsQueryResult,
        ));
      } catch (e) {
        emit(PodcastsFetchErrorState(
            message:
                'Failed to load podcasts from the server.\nThe server may be down.\nError: ${e.toString()}'));
      }
    });

    // PODCASTS query success
    // no episodes yet!
    on<PodcastsFetchSuccessEvent>((event, emit) async {
      emit(PodcastsFetchSuccessState(
        keyword: event.keyword,
        podcastsQueryResult: event.podcastsQueryResult,
        subscribedPodcasts: subscribedPodcasts,
      ));
    });

    ///

    /// Fill podcast with episodes
    // We fetch episodes for podcast by id
    on<FillPodcastWithEpisodesEvent>((event, emit) async {
      emit(PodcastFillingWithEpisodesState());
      try {
        final PodcastEntity podcastWithEpisodes =
            await podcastUseCases.fillPodcastWithEpisodes(event.podcast);
        add(FillPodcastWithEpisodesSuccessEvent(podcast: podcastWithEpisodes));
      } catch (e) {
        emit(PodcastFillWithEpisodesErrorState(
            message:
                'Failed to load episodes from the server.\nThe server may be down.\nError: ${e.toString()}'));
      }
    });

    // fetch episodes success
    on<FillPodcastWithEpisodesSuccessEvent>((event, emit) async {
      emit(PodcastFillWithEpisodesSuccessState(
        // We pass the query term and the query result so keyword and list are still alive when user navigates back to results page
        keyword: queryTerm,
        podcastsQueryResult: podcastsQueryResult,
        subscribedPodcasts: subscribedPodcasts,
        podcast: event.podcast,
      ));
    });

    ///

    /// SUBSCRIPTION
    on<SubscribeToPodcastEvent>((event, emit) async {
      void updateQueryResult(PodcastEntity podcast) {
        // Replace object in query result: necessary when user subscribes from within the results page
        // so podcast list item can be updated
        final int index = podcastsQueryResult.indexOf(event.podcast);
        podcastsQueryResult.removeAt(index);
        podcastsQueryResult.insert(index, podcast);
      }

      saveToDb(PodcastEntity podcast) async {
        // Set subscribed flag == true AND add episodes to podcast
        // Note that we don't copyWith episodes: ObjectBox requires list to be filled with add or addAll method
        final PodcastEntity podcastWithEpisodesSubscribed = podcast.copyWith(
          subscribed: true,
          unreadEpisodes: podcast.episodes.length,
        )..episodes.addAll(podcast.episodes);
        try {
          // Save to db
          await podcastUseCases
              .subscribeToPodcast(podcastWithEpisodesSubscribed)
              .whenComplete(() {
            updateQueryResult(podcastWithEpisodesSubscribed);
            subscribedPodcasts.add(podcastWithEpisodesSubscribed);
            emit(PodcastChangeSubscriptionState(
              podcast: podcastWithEpisodesSubscribed,
              subscribedPodcasts: subscribedPodcasts,
              podcastsQueryResult: podcastsQueryResult,
            ));
          });
        } catch (e) {
          emit(PodcastChangeSubscriptionErrorState(
              message:
                  'Failed to subscribe to podcast: ${event.podcast.title}'));
        }
      }

      getEpisodesForPodcast(PodcastEntity podcast) async {
        // Get the episodes so we can save podcast with episodes to db
        try {
          final PodcastEntity podcastWithEpisodes =
              await podcastUseCases.fillPodcastWithEpisodes(podcast);
          await saveToDb(podcastWithEpisodes);
        } catch (e) {
          emit(PodcastChangeSubscriptionErrorState(
              message:
                  'Failed to load episodes from the server.\nThe server may be down.\nError: ${e.toString()}'));
        }
      }

      // Check if podcast is already subscribed
      Map<int, int> podcastPIdMap =
          {}; // key = podcast pId, value = 0  (we need only the key for the check)

      for (PodcastEntity podcast in subscribedPodcasts) {
        podcastPIdMap[podcast.pId] = 0;
      }

      if (podcastPIdMap.containsKey(event.podcast.pId)) {
        // If key exists, podcast is already subscribed
        emit(PodcastChangeSubscriptionErrorState(
            message:
                'You already subscribed to the podcast: ${event.podcast.title}'));
      } else {
        await getEpisodesForPodcast(event.podcast);
      }
    });

    on<UnsubscribeFromPodcastEvent>((event, emit) async {
      try {
        // Create a copy with subscribed flag == false
        final PodcastEntity unSubscribedPodcast =
            event.podcast.copyWith(subscribed: false);

        /// Update UI data
        // Update query result list
        // Replace object in query result (only if object exists: we check this with the following map)
        Map<int, int> podcastPIdMap = {}; // key = podcast pId, value = 0
        for (PodcastEntity podcast in podcastsQueryResult) {
          podcastPIdMap[podcast.pId] = 0;
        }
        if (podcastPIdMap.containsKey(event.podcast.pId)) {
          int index = podcastsQueryResult.indexOf(event.podcast);
          podcastsQueryResult[index] = unSubscribedPodcast;
        }
        // Update subscribed podcasts list
        subscribedPodcasts.remove(event.podcast);

        ///

        // Remove from db
        await podcastUseCases.unsubscribeFromPodcast(event.podcast);

        // emit state
        emit(PodcastChangeSubscriptionState(
          podcast: event.podcast,
          subscribedPodcasts: subscribedPodcasts,
          podcastsQueryResult: podcastsQueryResult,
        ));
      } catch (e) {
        emit(PodcastChangeSubscriptionErrorState(
            message:
                'Failed to unsubscribe from podcast: ${event.podcast.title}'));
      }
    });

    ///
  }
}
