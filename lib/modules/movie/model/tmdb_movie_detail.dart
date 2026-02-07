import 'package:equatable/equatable.dart';
import 'package:movie_app/modules/movie/model/tmdb_credit.dart';
import 'package:movie_app/modules/movie/model/tmdb_genre.dart';
import 'package:movie_app/modules/movie/model/tmdb_movie.dart';
import 'package:movie_app/modules/movie/model/tmdb_review.dart';
import 'package:movie_app/modules/movie/model/tmdb_video.dart';
import 'package:movie_app/modules/movie/model/tmdb_watch_provider.dart';

/// Extended movie model with full details from append_to_response
class TMDBMovieDetail extends Equatable {
  // Basic info (from TMDBMovie)
  final int id;
  final String title;
  final String originalTitle;
  final String overview;
  final String? posterPath;
  final String? backdropPath;
  final double voteAverage;
  final int voteCount;
  final String? releaseDate;
  final bool? adult;
  final String? originalLanguage;
  final double? popularity;
  final bool isTVShow;
  final String mediaType;

  // Extended details
  final int? runtime;
  final int? budget;
  final int? revenue;
  final String? status;
  final String? tagline;
  final String? homepage;
  final String? imdbId;
  final List<TMDBGenre> genres;
  final List<TMDBProductionCompany> productionCompanies;
  final List<TMDBProductionCountry> productionCountries;
  final List<TMDBSpokenLanguage> spokenLanguages;

  // Append to response data
  final TMDBCredits? credits;
  final List<TMDBVideo> videos;
  final TMDBWatchProviderResult? watchProviders;
  final List<TMDBReview> reviews;
  final List<TMDBMovie> recommendations;
  final List<TMDBMovie> similar;
  final List<TMDBKeyword> keywords;
  final Map<String, dynamic>? externalIds;

  // For TV shows
  final int? numberOfSeasons;
  final int? numberOfEpisodes;
  final List<TMDBTVSeason>? seasons;
  final String? firstAirDate;
  final String? lastAirDate;
  final bool? inProduction;

  const TMDBMovieDetail({
    required this.id,
    required this.title,
    required this.originalTitle,
    required this.overview,
    this.posterPath,
    this.backdropPath,
    required this.voteAverage,
    required this.voteCount,
    this.releaseDate,
    this.adult,
    this.originalLanguage,
    this.popularity,
    required this.isTVShow,
    required this.mediaType,
    this.runtime,
    this.budget,
    this.revenue,
    this.status,
    this.tagline,
    this.homepage,
    this.imdbId,
    this.genres = const [],
    this.productionCompanies = const [],
    this.productionCountries = const [],
    this.spokenLanguages = const [],
    this.credits,
    this.videos = const [],
    this.watchProviders,
    this.reviews = const [],
    this.recommendations = const [],
    this.similar = const [],
    this.keywords = const [],
    this.externalIds,
    this.numberOfSeasons,
    this.numberOfEpisodes,
    this.seasons,
    this.firstAirDate,
    this.lastAirDate,
    this.inProduction,
  });

  factory TMDBMovieDetail.fromJson(
    Map<String, dynamic> json, {
    bool isTVShow = false,
  }) {
    // Parse genres
    final genres =
        (json['genres'] as List<dynamic>?)
            ?.map((e) => TMDBGenre.fromJson(e))
            .toList() ??
        [];

    // Parse credits
    final creditsJson = json['credits'] ?? json['aggregate_credits'];
    final credits = creditsJson != null
        ? TMDBCredits.fromJson(creditsJson)
        : null;

    // Parse videos
    final videosJson = json['videos'] as Map<String, dynamic>?;
    final videos =
        (videosJson?['results'] as List<dynamic>?)
            ?.map((e) => TMDBVideo.fromJson(e))
            .toList() ??
        [];

    // Parse watch providers for VN
    final watchProvidersJson = json['watch/providers'] as Map<String, dynamic>?;
    final watchProvidersResults =
        watchProvidersJson?['results'] as Map<String, dynamic>?;
    final vnProviders = watchProvidersResults?['VN'] as Map<String, dynamic>?;
    final watchProviders = vnProviders != null
        ? TMDBWatchProviderResult.fromJson(vnProviders)
        : null;

    // Parse reviews
    final reviewsJson = json['reviews'] as Map<String, dynamic>?;
    final reviews =
        (reviewsJson?['results'] as List<dynamic>?)
            ?.map((e) => TMDBReview.fromJson(e))
            .toList() ??
        [];

    // Parse recommendations
    final recommendationsJson =
        json['recommendations'] as Map<String, dynamic>?;
    final recommendations =
        (recommendationsJson?['results'] as List<dynamic>?)
            ?.map((e) => TMDBMovie.fromJson(e, isTVShow: isTVShow))
            .toList() ??
        [];

    // Parse similar
    final similarJson = json['similar'] as Map<String, dynamic>?;
    final similar =
        (similarJson?['results'] as List<dynamic>?)
            ?.map((e) => TMDBMovie.fromJson(e, isTVShow: isTVShow))
            .toList() ??
        [];

    // Parse keywords
    final keywordsJson = json['keywords'] as Map<String, dynamic>?;
    final keywordsList = keywordsJson?['keywords'] ?? keywordsJson?['results'];
    final keywords =
        (keywordsList as List<dynamic>?)
            ?.map((e) => TMDBKeyword.fromJson(e))
            .toList() ??
        [];

    // Parse production companies
    final productionCompanies =
        (json['production_companies'] as List<dynamic>?)
            ?.map((e) => TMDBProductionCompany.fromJson(e))
            .toList() ??
        [];

    // Parse production countries
    final productionCountries =
        (json['production_countries'] as List<dynamic>?)
            ?.map((e) => TMDBProductionCountry.fromJson(e))
            .toList() ??
        [];

    // Parse spoken languages
    final spokenLanguages =
        (json['spoken_languages'] as List<dynamic>?)
            ?.map((e) => TMDBSpokenLanguage.fromJson(e))
            .toList() ??
        [];

    // Parse TV seasons
    final seasons = isTVShow
        ? (json['seasons'] as List<dynamic>?)
                  ?.map((e) => TMDBTVSeason.fromJson(e))
                  .toList() ??
              []
        : null;

    return TMDBMovieDetail(
      id: json['id'] ?? 0,
      title: isTVShow
          ? (json['name'] ?? json['original_name'] ?? 'Unknown')
          : (json['title'] ?? json['original_title'] ?? 'Unknown'),
      originalTitle: isTVShow
          ? (json['original_name'] ?? 'Unknown')
          : (json['original_title'] ?? 'Unknown'),
      overview: json['overview'] ?? '',
      posterPath: json['poster_path'],
      backdropPath: json['backdrop_path'],
      voteAverage: (json['vote_average'] ?? 0).toDouble(),
      voteCount: json['vote_count'] ?? 0,
      releaseDate: isTVShow ? json['first_air_date'] : json['release_date'],
      adult: json['adult'],
      originalLanguage: json['original_language'],
      popularity: (json['popularity'] ?? 0).toDouble(),
      isTVShow: isTVShow,
      mediaType: isTVShow ? 'tv' : 'movie',
      runtime: isTVShow
          ? (json['episode_run_time'] as List?)?.isNotEmpty == true
                ? json['episode_run_time'][0]
                : null
          : json['runtime'],
      budget: json['budget'],
      revenue: json['revenue'],
      status: json['status'],
      tagline: json['tagline'],
      homepage: json['homepage'],
      imdbId: json['imdb_id'],
      genres: genres,
      productionCompanies: productionCompanies,
      productionCountries: productionCountries,
      spokenLanguages: spokenLanguages,
      credits: credits,
      videos: videos,
      watchProviders: watchProviders,
      reviews: reviews,
      recommendations: recommendations,
      similar: similar,
      keywords: keywords,
      externalIds: json['external_ids'],
      numberOfSeasons: json['number_of_seasons'],
      numberOfEpisodes: json['number_of_episodes'],
      seasons: seasons,
      firstAirDate: json['first_air_date'],
      lastAirDate: json['last_air_date'],
      inProduction: json['in_production'],
    );
  }

  /// Convert to basic TMDBMovie for navigation
  TMDBMovie toTMDBMovie() {
    return TMDBMovie(
      id: id,
      title: title,
      originalTitle: originalTitle,
      overview: overview,
      posterPath: posterPath,
      backdropPath: backdropPath,
      voteAverage: voteAverage,
      voteCount: voteCount,
      releaseDate: releaseDate,
      genreIds: genres.map((g) => g.id).toList(),
      adult: adult,
      originalLanguage: originalLanguage,
      popularity: popularity,
      isTVShow: isTVShow,
      mediaType: mediaType,
    );
  }

  /// Get formatted runtime (e.g., "2h 15m")
  String? get formattedRuntime {
    if (runtime == null || runtime == 0) return null;
    final hours = runtime! ~/ 60;
    final minutes = runtime! % 60;
    if (hours > 0 && minutes > 0) return '${hours}h ${minutes}m';
    if (hours > 0) return '${hours}h';
    return '${minutes}m';
  }

  /// Get formatted budget (e.g., "$150M")
  String? get formattedBudget {
    if (budget == null || budget == 0) return null;
    if (budget! >= 1000000000) {
      return '\$${(budget! / 1000000000).toStringAsFixed(1)}B';
    }
    if (budget! >= 1000000) {
      return '\$${(budget! / 1000000).toStringAsFixed(0)}M';
    }
    return '\$$budget';
  }

  /// Get formatted revenue
  String? get formattedRevenue {
    if (revenue == null || revenue == 0) return null;
    if (revenue! >= 1000000000) {
      return '\$${(revenue! / 1000000000).toStringAsFixed(2)}B';
    }
    if (revenue! >= 1000000) {
      return '\$${(revenue! / 1000000).toStringAsFixed(1)}M';
    }
    return '\$$revenue';
  }

  /// Get release year
  String get year {
    final date = releaseDate ?? firstAirDate;
    if (date == null || date.isEmpty) return 'N/A';
    return date.split('-').first;
  }

  /// Get trailer video
  TMDBVideo? get trailer => videos.firstWhere(
    (v) =>
        v.type?.toLowerCase() == 'trailer' &&
        v.site?.toLowerCase() == 'youtube',
    orElse: () => videos.isNotEmpty ? videos.first : TMDBVideo.empty(),
  );

  /// Get genre names as comma-separated string
  String get genreString => genres.map((g) => g.name).join(', ');

  @override
  List<Object?> get props => [id, title, isTVShow];
}

// Supporting models

class TMDBProductionCompany extends Equatable {
  final int id;
  final String name;
  final String? logoPath;
  final String? originCountry;

  const TMDBProductionCompany({
    required this.id,
    required this.name,
    this.logoPath,
    this.originCountry,
  });

  factory TMDBProductionCompany.fromJson(Map<String, dynamic> json) {
    return TMDBProductionCompany(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Unknown',
      logoPath: json['logo_path'],
      originCountry: json['origin_country'],
    );
  }

  @override
  List<Object?> get props => [id, name];
}

class TMDBProductionCountry extends Equatable {
  final String iso31661;
  final String name;

  const TMDBProductionCountry({required this.iso31661, required this.name});

  factory TMDBProductionCountry.fromJson(Map<String, dynamic> json) {
    return TMDBProductionCountry(
      iso31661: json['iso_3166_1'] ?? '',
      name: json['name'] ?? '',
    );
  }

  @override
  List<Object?> get props => [iso31661, name];
}

class TMDBSpokenLanguage extends Equatable {
  final String iso6391;
  final String name;
  final String? englishName;

  const TMDBSpokenLanguage({
    required this.iso6391,
    required this.name,
    this.englishName,
  });

  factory TMDBSpokenLanguage.fromJson(Map<String, dynamic> json) {
    return TMDBSpokenLanguage(
      iso6391: json['iso_639_1'] ?? '',
      name: json['name'] ?? '',
      englishName: json['english_name'],
    );
  }

  @override
  List<Object?> get props => [iso6391, name];
}

class TMDBKeyword extends Equatable {
  final int id;
  final String name;

  const TMDBKeyword({required this.id, required this.name});

  factory TMDBKeyword.fromJson(Map<String, dynamic> json) {
    return TMDBKeyword(id: json['id'] ?? 0, name: json['name'] ?? '');
  }

  @override
  List<Object?> get props => [id, name];
}

class TMDBTVSeason extends Equatable {
  final int id;
  final String name;
  final String? overview;
  final String? posterPath;
  final int seasonNumber;
  final int? episodeCount;
  final String? airDate;
  final double? voteAverage;

  const TMDBTVSeason({
    required this.id,
    required this.name,
    this.overview,
    this.posterPath,
    required this.seasonNumber,
    this.episodeCount,
    this.airDate,
    this.voteAverage,
  });

  factory TMDBTVSeason.fromJson(Map<String, dynamic> json) {
    return TMDBTVSeason(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Season ${json['season_number'] ?? 0}',
      overview: json['overview'],
      posterPath: json['poster_path'],
      seasonNumber: json['season_number'] ?? 0,
      episodeCount: json['episode_count'],
      airDate: json['air_date'],
      voteAverage: (json['vote_average'] ?? 0).toDouble(),
    );
  }

  @override
  List<Object?> get props => [id, seasonNumber];
}
