import 'package:movie_app/constrains/env/env.dart';

class EndpointTmdb {
  static int page = 1;
  static String language = 'vi-VN';
  static String region = 'VN';

  static String get apiKey => Env.apiKey;
  static String get apiAccessToken => Env.apiAccessToken;
  static String get baseUrl => Env.baseUrl;
  static String get imageBaseUrl => Env.imageBaseUrl;
  static String get accountId => Env.accountId;

  // ============ CONFIGURATION ============
  static String get getConfiguration => '$baseUrl/configuration';

  // ============ TRENDING ============
  /// mediaType: all, movie, tv, person
  /// timeWindow: day, week
  static String getTrending(String mediaType, String timeWindow) =>
      '$baseUrl/trending/$mediaType/$timeWindow?language=$language&page=$page';

  static String get getTrendingAll => getTrending('all', 'week');
  static String get getTrendingMovies => getTrending('movie', 'week');
  static String get getTrendingTV => getTrending('tv', 'week');
  static String get getTrendingPerson => getTrending('person', 'week');

  // ============ MOVIES ============
  static String get getPopularMovies =>
      '$baseUrl/movie/popular?language=$language&page=$page&region=$region';

  static String get getTopRatedMovies =>
      '$baseUrl/movie/top_rated?language=$language&page=$page&region=$region';

  static String get getNowPlayingMovies =>
      '$baseUrl/movie/now_playing?language=$language&page=$page&region=$region';

  static String get getUpcomingMovies =>
      '$baseUrl/movie/upcoming?language=$language&page=$page&region=$region';

  static String getMovieDetails(int movieId, {String? appendToResponse}) {
    final append =
        appendToResponse ??
        'credits,images,videos,watch/providers,reviews,recommendations,similar,keywords';
    return '$baseUrl/movie/$movieId?language=$language&append_to_response=$append';
  }

  static String getMovieVideos(int movieId) =>
      '$baseUrl/movie/$movieId/videos?language=$language';

  static String getMovieCredits(int movieId) =>
      '$baseUrl/movie/$movieId/credits?language=$language';

  static String getMovieWatchProviders(int movieId) =>
      '$baseUrl/movie/$movieId/watch/providers';

  static String getSimilarMovies(int movieId) =>
      '$baseUrl/movie/$movieId/similar?language=$language&page=$page';

  static String getMovieRecommendations(int movieId) =>
      '$baseUrl/movie/$movieId/recommendations?language=$language&page=$page';

  // ============ TV SHOWS ============
  static String get getPopularTVShows =>
      '$baseUrl/tv/popular?language=$language&page=$page';

  static String get getTopRatedTV =>
      '$baseUrl/tv/top_rated?language=$language&page=$page';

  static String get getAiringTodayTV =>
      '$baseUrl/tv/airing_today?language=$language&page=$page';

  static String get getOnTheAirTV =>
      '$baseUrl/tv/on_the_air?language=$language&page=$page';

  static String getTVDetails(int tvId, {String? appendToResponse}) {
    final append =
        appendToResponse ??
        'aggregate_credits,images,videos,watch/providers,reviews,recommendations,similar';
    return '$baseUrl/tv/$tvId?language=$language&append_to_response=$append';
  }

  static String getTVSeasonDetails(int tvId, int seasonNumber) =>
      '$baseUrl/tv/$tvId/season/$seasonNumber?language=$language&append_to_response=credits,images,videos';

  static String getTVEpisodeDetails(
    int tvId,
    int seasonNumber,
    int episodeNumber,
  ) =>
      '$baseUrl/tv/$tvId/season/$seasonNumber/episode/$episodeNumber?language=$language&append_to_response=credits,images';

  // ============ DISCOVER ============
  static String discoverMovies({
    List<int>? withGenres,
    List<int>? withoutGenres,
    int? year,
    String? releaseDateGte,
    String? releaseDateLte,
    double? voteAverageGte,
    int? voteCountGte,
    String sortBy = 'popularity.desc',
    List<int>? withWatchProviders,
    String? watchRegion,
    String? withWatchMonetizationTypes,
    int page = 1,
  }) {
    final params = <String, String>{
      'language': language,
      'page': page.toString(),
      'sort_by': sortBy,
    };

    if (withGenres != null && withGenres.isNotEmpty) {
      params['with_genres'] = withGenres.join(',');
    }
    if (withoutGenres != null && withoutGenres.isNotEmpty) {
      params['without_genres'] = withoutGenres.join('|');
    }
    if (year != null) {
      params['primary_release_year'] = year.toString();
    }
    if (releaseDateGte != null) {
      params['primary_release_date.gte'] = releaseDateGte;
    }
    if (releaseDateLte != null) {
      params['primary_release_date.lte'] = releaseDateLte;
    }
    if (voteAverageGte != null) {
      params['vote_average.gte'] = voteAverageGte.toString();
    }
    if (voteCountGte != null) {
      params['vote_count.gte'] = voteCountGte.toString();
    }
    if (withWatchProviders != null && withWatchProviders.isNotEmpty) {
      params['with_watch_providers'] = withWatchProviders.join('|');
      params['watch_region'] = watchRegion ?? region;
    }
    if (withWatchMonetizationTypes != null) {
      params['with_watch_monetization_types'] = withWatchMonetizationTypes;
    }

    final queryString = params.entries
        .map((e) => '${e.key}=${e.value}')
        .join('&');
    return '$baseUrl/discover/movie?$queryString';
  }

  static String discoverTV({
    List<int>? withGenres,
    int? firstAirYear,
    String? firstAirDateGte,
    String? firstAirDateLte,
    double? voteAverageGte,
    int? voteCountGte,
    String sortBy = 'popularity.desc',
    int page = 1,
  }) {
    final params = <String, String>{
      'language': language,
      'page': page.toString(),
      'sort_by': sortBy,
    };

    if (withGenres != null && withGenres.isNotEmpty) {
      params['with_genres'] = withGenres.join(',');
    }
    if (firstAirYear != null) {
      params['first_air_date_year'] = firstAirYear.toString();
    }
    if (firstAirDateGte != null) {
      params['first_air_date.gte'] = firstAirDateGte;
    }
    if (firstAirDateLte != null) {
      params['first_air_date.lte'] = firstAirDateLte;
    }
    if (voteAverageGte != null) {
      params['vote_average.gte'] = voteAverageGte.toString();
    }
    if (voteCountGte != null) {
      params['vote_count.gte'] = voteCountGte.toString();
    }

    final queryString = params.entries
        .map((e) => '${e.key}=${e.value}')
        .join('&');
    return '$baseUrl/discover/tv?$queryString';
  }

  // ============ SEARCH ============
  static String searchMulti(String query, {int page = 1}) =>
      '$baseUrl/search/multi?query=${Uri.encodeComponent(query)}&include_adult=false&language=$language&page=$page';

  static String searchMovies(String query, {int page = 1}) =>
      '$baseUrl/search/movie?query=${Uri.encodeComponent(query)}&include_adult=false&language=$language&page=$page';

  static String searchTV(String query, {int page = 1}) =>
      '$baseUrl/search/tv?query=${Uri.encodeComponent(query)}&include_adult=false&language=$language&page=$page';

  static String searchPerson(String query, {int page = 1}) =>
      '$baseUrl/search/person?query=${Uri.encodeComponent(query)}&include_adult=false&language=$language&page=$page';

  static String searchCollection(String query, {int page = 1}) =>
      '$baseUrl/search/collection?query=${Uri.encodeComponent(query)}&include_adult=false&language=$language&page=$page';

  static String searchKeyword(String query, {int page = 1}) =>
      '$baseUrl/search/keyword?query=${Uri.encodeComponent(query)}&page=$page';

  // ============ FIND ============
  static String findByExternalId(
    String externalId, {
    String externalSource = 'imdb_id',
  }) =>
      '$baseUrl/find/$externalId?external_source=$externalSource&language=$language';

  // ============ PERSON ============
  static String getPersonDetails(int personId) =>
      '$baseUrl/person/$personId?language=$language&append_to_response=combined_credits,images,external_ids';

  static String getPersonCombinedCredits(int personId) =>
      '$baseUrl/person/$personId/combined_credits?language=$language';

  // ============ GENRES ============
  static String get getMovieGenres =>
      '$baseUrl/genre/movie/list?language=$language';
  static String get getTVGenres => '$baseUrl/genre/tv/list?language=$language';

  // ============ ACCOUNT & AUTH ============
  static String getAccountDetails(int accountId) =>
      '$baseUrl/account/$accountId';

  // Request Token
  static String get createRequestToken => '$baseUrl/authentication/token/new';

  // Session
  static String get createSession => '$baseUrl/authentication/session/new';
  static String get createGuestSession =>
      '$baseUrl/authentication/guest_session/new';
  static String get deleteSession => '$baseUrl/authentication/session';

  // Account States
  static String getMovieAccountStates(int movieId, String sessionId) =>
      '$baseUrl/movie/$movieId/account_states?session_id=$sessionId';

  static String getTVAccountStates(int tvId, String sessionId) =>
      '$baseUrl/tv/$tvId/account_states?session_id=$sessionId';

  // Rating
  static String rateMovie(int movieId, String sessionId) =>
      '$baseUrl/movie/$movieId/rating?session_id=$sessionId';

  static String rateTV(int tvId, String sessionId) =>
      '$baseUrl/tv/$tvId/rating?session_id=$sessionId';

  // Favorite
  static String addFavorite(int accountId, String sessionId) =>
      '$baseUrl/account/$accountId/favorite?session_id=$sessionId';

  static String getFavoriteMovies(int accountId, String sessionId) =>
      '$baseUrl/account/$accountId/favorite/movies?session_id=$sessionId&language=$language&page=$page&sort_by=created_at.desc';

  static String getFavoriteTV(int accountId, String sessionId) =>
      '$baseUrl/account/$accountId/favorite/tv?session_id=$sessionId&language=$language&page=$page&sort_by=created_at.desc';

  // Watchlist
  static String addWatchlist(int accountId, String sessionId) =>
      '$baseUrl/account/$accountId/watchlist?session_id=$sessionId';

  static String getWatchlistMovies(int accountId, String sessionId) =>
      '$baseUrl/account/$accountId/watchlist/movies?session_id=$sessionId&language=$language&page=$page&sort_by=created_at.desc';

  static String getWatchlistTV(int accountId, String sessionId) =>
      '$baseUrl/account/$accountId/watchlist/tv?session_id=$sessionId&language=$language&page=$page&sort_by=created_at.desc';

  // Rated
  static String getRatedMovies(int accountId, String sessionId) =>
      '$baseUrl/account/$accountId/rated/movies?session_id=$sessionId&language=$language&page=$page&sort_by=created_at.desc';

  static String getRatedTV(int accountId, String sessionId) =>
      '$baseUrl/account/$accountId/rated/tv?session_id=$sessionId&language=$language&page=$page&sort_by=created_at.desc';

  // ============ COLLECTIONS ============
  static String getCollection(int collectionId) =>
      '$baseUrl/collection/$collectionId?language=$language';

  // ============ KEYWORDS ============
  static String getKeywordMovies(int keywordId) =>
      '$baseUrl/keyword/$keywordId/movies?language=$language&page=$page';

  // ============ CERTIFICATIONS ============
  static String get getMovieCertifications =>
      '$baseUrl/certification/movie/list';
  static String get getTVCertifications => '$baseUrl/certification/tv/list';
}
