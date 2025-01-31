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
    String queryTerm = '';
    List<PodcastEntity> podcastsQueryResult = [];
    List<PodcastEntity> subscribedPodcasts = [];

    /// REMOTE: FIND PODCASTS
    // podcasts by keyword: we get a list
    on<FindPodcastsPressedEvent>((event, emit) async {
      queryTerm = event.keyword;
      emit(PodcastsFetchingState());
      podcastsQueryResult = await podcastUseCases.fetchPodcasts(queryTerm);
      add(PodcastsReceivedEvent(
        keyword: queryTerm,
        podcasts: podcastsQueryResult,
      ));
    });

    // PODCASTS received
    // no episodes yet!
    on<PodcastsReceivedEvent>((event, emit) async {
      emit(PodcastsReceivedState(
        keyword: event.keyword,
        podcasts: event.podcasts,
        subscribedPodcasts: subscribedPodcasts,
      ));
    });

    ///

    /// Fill podcast with episodes
    // We fetch episodes for podcast by id
    on<FillPodcastWithEpisodesPressedEvent>((event, emit) async {
      emit(PodcastsFillingWithEpisodesState());
      final PodcastEntity podcastWithEpisodes =
          await podcastUseCases.fillPodcastWithEpisodes(event.podcast);
      add(PodcastFilledWithEpisodesEvent(podcast: podcastWithEpisodes));
    });

    // Given podcast is filled with episodes
    on<PodcastFilledWithEpisodesEvent>((event, emit) async {
      emit(PodcastFilledWithEpisodesState(
        // We pass the query term and the query result so keyword and list are still alive when user navigates back to results page
        keyword: queryTerm,
        podcasts: podcastsQueryResult,
        subscribedPodcasts: subscribedPodcasts,
        podcast: event.podcast,
      ));
    });

    ///

    /// LOCAL: SUBSCRIBED PODCASTS
    on<GetSubscribedPodcastsEvent>((event, emit) async {
      emit(FetchingSubscribedPodcastsState());
      subscribedPodcasts = await podcastUseCases.getSubscribedPodcasts();
      emit(GotSubscribedPodcastsState(podcasts: subscribedPodcasts));
    });

    ///

    /// SUBSCRIPTION
    on<SubscribeToPodcastEvent>((event, emit) async {
      final PodcastEntity podcastWithEpisodes =
          await podcastUseCases.fillPodcastWithEpisodes(event.podcast);
      final PodcastEntity subscribedPodcast =
          podcastWithEpisodes.copyWith(subscribed: true);
      await podcastUseCases.subscribeToPodcast(subscribedPodcast);
      subscribedPodcasts.add(subscribedPodcast);
      emit(GotSubscribedPodcastsState(podcasts: subscribedPodcasts));
      /*emit(PodcastIsSubscribedState(
        podcast: subscribedPodcast,
        subscribedPodcasts: subscribedPodcasts,
      ));*/
    });

    on<UnsubscribeFromPodcastEvent>((event, emit) async {
      await podcastUseCases.unsubscribeFromPodcast(event.podcast);
      subscribedPodcasts.remove(event.podcast);
      emit(GotSubscribedPodcastsState(podcasts: subscribedPodcasts));
     /* emit(PodcastIsUnsubscribedState(
        podcast: event.podcast,
        subscribedPodcasts: subscribedPodcasts,
      ));*/
    });

    ///
  }
}
