import 'package:equatable/equatable.dart';
import 'package:movie_app/modules/movie/model/tmdb_movie.dart';
import 'package:movie_app/modules/movie/model/tmdb_credit.dart';

/// Represents a person (actor, director, etc.)
class TMDBPerson extends Equatable {
  final int id;
  final String name;
  final String? profilePath;
  final String? biography;
  final String? birthday;
  final String? deathday;
  final String? placeOfBirth;
  final String? knownForDepartment;
  final double? popularity;
  final bool? adult;
  final int? gender;
  final String? homepage;
  final String? alsoKnownAs;
  final String? imdbId;
  final List<TMDBPersonCredit> combinedCredits;
  final List<String> images;
  final Map<String, String?>? externalIds;

  const TMDBPerson({
    required this.id,
    required this.name,
    this.profilePath,
    this.biography,
    this.birthday,
    this.deathday,
    this.placeOfBirth,
    this.knownForDepartment,
    this.popularity,
    this.adult,
    this.gender,
    this.homepage,
    this.alsoKnownAs,
    this.imdbId,
    this.combinedCredits = const [],
    this.images = const [],
    this.externalIds,
  });

  factory TMDBPerson.fromJson(Map<String, dynamic> json) {
    // Parse combined credits
    final combinedCreditsJson =
        json['combined_credits'] as Map<String, dynamic>?;
    List<TMDBPersonCredit> credits = [];
    if (combinedCreditsJson != null) {
      final castCredits =
          (combinedCreditsJson['cast'] as List<dynamic>?)
              ?.map((e) => TMDBPersonCredit.fromJson(e, creditType: 'cast'))
              .toList() ??
          [];
      final crewCredits =
          (combinedCreditsJson['crew'] as List<dynamic>?)
              ?.map((e) => TMDBPersonCredit.fromJson(e, creditType: 'crew'))
              .toList() ??
          [];
      credits = [...castCredits, ...crewCredits];
    }

    // Parse images
    final imagesJson = json['images'] as Map<String, dynamic>?;
    final profiles =
        (imagesJson?['profiles'] as List<dynamic>?)
            ?.map((e) => e['file_path'] as String?)
            .whereType<String>()
            .toList() ??
        [];

    // Parse external IDs
    final externalIdsJson = json['external_ids'] as Map<String, dynamic>?;

    return TMDBPerson(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Unknown',
      profilePath: json['profile_path'],
      biography: json['biography'],
      birthday: json['birthday'],
      deathday: json['deathday'],
      placeOfBirth: json['place_of_birth'],
      knownForDepartment: json['known_for_department'],
      popularity: (json['popularity'] ?? 0).toDouble(),
      adult: json['adult'],
      gender: json['gender'],
      homepage: json['homepage'],
      alsoKnownAs: (json['also_known_as'] as List?)?.join(', '),
      imdbId: json['imdb_id'],
      combinedCredits: credits,
      images: profiles,
      externalIds: externalIdsJson?.map(
        (key, value) => MapEntry(key, value?.toString()),
      ),
    );
  }

  /// Check if this person is alive
  bool get isAlive => deathday == null || deathday!.isEmpty;

  /// Get age (or age at death)
  int? get age {
    if (birthday == null || birthday!.isEmpty) return null;
    try {
      final birthDate = DateTime.parse(birthday!);
      final endDate = (deathday != null && deathday!.isNotEmpty)
          ? DateTime.parse(deathday!)
          : DateTime.now();
      return endDate.year - birthDate.year;
    } catch (e) {
      return null;
    }
  }

  /// Get movie credits only
  List<TMDBPersonCredit> get movieCredits =>
      combinedCredits.where((c) => c.mediaType == 'movie').toList();

  /// Get TV credits only
  List<TMDBPersonCredit> get tvCredits =>
      combinedCredits.where((c) => c.mediaType == 'tv').toList();

  /// Get acting credits
  List<TMDBPersonCredit> get actingCredits =>
      combinedCredits.where((c) => c.creditType == 'cast').toList();

  /// Get directing credits
  List<TMDBPersonCredit> get directingCredits => combinedCredits
      .where(
        (c) => c.creditType == 'crew' && c.job?.toLowerCase() == 'director',
      )
      .toList();

  @override
  List<Object?> get props => [id, name, profilePath];
}

/// Represents a credit from a person's filmography
class TMDBPersonCredit extends Equatable {
  final int id;
  final String title;
  final String? posterPath;
  final String? backdropPath;
  final String mediaType; // movie or tv
  final String creditType; // cast or crew
  final String? character;
  final String? job;
  final String? department;
  final String? releaseDate;
  final double? voteAverage;
  final int? voteCount;
  final String? overview;
  final int? episodeCount; // For TV

  const TMDBPersonCredit({
    required this.id,
    required this.title,
    this.posterPath,
    this.backdropPath,
    required this.mediaType,
    required this.creditType,
    this.character,
    this.job,
    this.department,
    this.releaseDate,
    this.voteAverage,
    this.voteCount,
    this.overview,
    this.episodeCount,
  });

  factory TMDBPersonCredit.fromJson(
    Map<String, dynamic> json, {
    required String creditType,
  }) {
    final isTV = json['media_type'] == 'tv';

    return TMDBPersonCredit(
      id: json['id'] ?? 0,
      title: isTV
          ? (json['name'] ?? json['original_name'] ?? 'Unknown')
          : (json['title'] ?? json['original_title'] ?? 'Unknown'),
      posterPath: json['poster_path'],
      backdropPath: json['backdrop_path'],
      mediaType: json['media_type'] ?? (isTV ? 'tv' : 'movie'),
      creditType: creditType,
      character: json['character'],
      job: json['job'],
      department: json['department'],
      releaseDate: isTV ? json['first_air_date'] : json['release_date'],
      voteAverage: (json['vote_average'] ?? 0).toDouble(),
      voteCount: json['vote_count'],
      overview: json['overview'],
      episodeCount: json['episode_count'],
    );
  }

  /// Get release year
  String get year {
    if (releaseDate == null || releaseDate!.isEmpty) return 'TBA';
    return releaseDate!.split('-').first;
  }

  /// Convert to TMDBMovie for navigation
  TMDBMovie toTMDBMovie() {
    return TMDBMovie(
      id: id,
      title: title,
      originalTitle: title,
      overview: overview ?? '',
      posterPath: posterPath,
      backdropPath: backdropPath,
      voteAverage: voteAverage ?? 0,
      voteCount: voteCount ?? 0,
      releaseDate: releaseDate,
      genreIds: [],
      adult: false,
      originalLanguage: 'en',
      popularity: 0,
      isTVShow: mediaType == 'tv',
      mediaType: mediaType,
    );
  }

  @override
  List<Object?> get props => [id, title, mediaType, character, job];
}
