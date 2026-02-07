import 'package:equatable/equatable.dart';
import 'package:movie_app/modules/movie/model/tmdb_movie.dart';

/// Represents a watch provider (Netflix, HBO, etc.)
class TMDBWatchProvider extends Equatable {
  final int providerId;
  final String providerName;
  final String? logoPath;
  final int displayPriority;

  const TMDBWatchProvider({
    required this.providerId,
    required this.providerName,
    this.logoPath,
    this.displayPriority = 0,
  });

  factory TMDBWatchProvider.fromJson(Map<String, dynamic> json) {
    return TMDBWatchProvider(
      providerId: json['provider_id'] ?? 0,
      providerName: json['provider_name'] ?? 'Unknown',
      logoPath: json['logo_path'],
      displayPriority: json['display_priority'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'provider_id': providerId,
      'provider_name': providerName,
      'logo_path': logoPath,
      'display_priority': displayPriority,
    };
  }

  @override
  List<Object?> get props => [providerId, providerName, logoPath];
}

/// Watch providers result for a specific region
class TMDBWatchProviderResult extends Equatable {
  final String? link; // Link to TMDB watch page
  final List<TMDBWatchProvider> flatrate; // Streaming (Netflix, Disney+, etc.)
  final List<TMDBWatchProvider> rent; // Rent options
  final List<TMDBWatchProvider> buy; // Buy options
  final List<TMDBWatchProvider> free; // Free with ads
  final List<TMDBWatchProvider> ads; // Free with ads (alias)

  const TMDBWatchProviderResult({
    this.link,
    this.flatrate = const [],
    this.rent = const [],
    this.buy = const [],
    this.free = const [],
    this.ads = const [],
  });

  factory TMDBWatchProviderResult.fromJson(Map<String, dynamic> json) {
    return TMDBWatchProviderResult(
      link: json['link'],
      flatrate:
          (json['flatrate'] as List<dynamic>?)
              ?.map((e) => TMDBWatchProvider.fromJson(e))
              .toList() ??
          [],
      rent:
          (json['rent'] as List<dynamic>?)
              ?.map((e) => TMDBWatchProvider.fromJson(e))
              .toList() ??
          [],
      buy:
          (json['buy'] as List<dynamic>?)
              ?.map((e) => TMDBWatchProvider.fromJson(e))
              .toList() ??
          [],
      free:
          (json['free'] as List<dynamic>?)
              ?.map((e) => TMDBWatchProvider.fromJson(e))
              .toList() ??
          [],
      ads:
          (json['ads'] as List<dynamic>?)
              ?.map((e) => TMDBWatchProvider.fromJson(e))
              .toList() ??
          [],
    );
  }

  /// Check if there are any streaming options available
  bool get hasStreaming => flatrate.isNotEmpty;

  /// Get all available providers (streaming + free)
  List<TMDBWatchProvider> get allFreeOptions => [...flatrate, ...free, ...ads];

  /// Get all rent/buy options
  List<TMDBWatchProvider> get paidOptions => [...rent, ...buy];

  @override
  List<Object?> get props => [link, flatrate, rent, buy, free, ads];
}

/// Full watch providers response with results by country
class TMDBWatchProviders extends Equatable {
  final int id;
  final Map<String, TMDBWatchProviderResult> results;

  const TMDBWatchProviders({required this.id, required this.results});

  factory TMDBWatchProviders.fromJson(Map<String, dynamic> json) {
    final resultsJson = json['results'] as Map<String, dynamic>? ?? {};
    final results = resultsJson.map(
      (key, value) => MapEntry(key, TMDBWatchProviderResult.fromJson(value)),
    );

    return TMDBWatchProviders(id: json['id'] ?? 0, results: results);
  }

  /// Get watch providers for Vietnam
  TMDBWatchProviderResult? get vn => results['VN'];

  /// Get watch providers for a specific country
  TMDBWatchProviderResult? forCountry(String countryCode) =>
      results[countryCode.toUpperCase()];

  @override
  List<Object?> get props => [id, results];
}
