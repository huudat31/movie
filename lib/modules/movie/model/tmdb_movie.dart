import 'package:equatable/equatable.dart';

class TMDBMovie extends Equatable {
  final int id;
  final String title;
  final String originalTitle;
  final String overview;
  final String? posterPath;
  final String? backdropPath;
  final double voteAverage;
  final int voteCount;
  final String? releaseDate;
  final List<int> genreIds;
  final bool? adult;
  final String? originalLanguage;
  final double? popularity;
  final bool isTVShow;
  final String mediaType;

  TMDBMovie({
    required this.id,
    required this.title,
    required this.originalTitle,
    required this.overview,
    required this.posterPath,
    required this.backdropPath,
    required this.voteAverage,
    required this.voteCount,
    required this.releaseDate,
    required this.genreIds,
    required this.adult,
    required this.originalLanguage,
    required this.popularity,
    required this.isTVShow,
    required this.mediaType,
  });

  factory TMDBMovie.fromJson(
    Map<String, dynamic> json, {
    bool isTVShow = false,
  }) {
    return TMDBMovie(
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
      genreIds: json['genre_ids'] != null
          ? List<int>.from(json['genre_ids'])
          : [],
      adult: json['adult'] ?? false,
      originalLanguage: json['original_language'] ?? 'en',
      popularity: (json['popularity'] ?? 0).toDouble(),
      isTVShow: isTVShow,
      mediaType: json['media_type'] ?? (isTVShow ? 'tv' : 'movie'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'original_title': originalTitle,
      'overview': overview,
      'poster_path': posterPath,
      'backdrop_path': backdropPath,
      'vote_average': voteAverage,
      'vote_count': voteCount,
      'release_date': releaseDate,
      'genre_ids': genreIds,
      'adult': adult,
      'original_language': originalLanguage,
      'popularity': popularity,
      'is_tv_show': isTVShow,
      'media_type': mediaType,
    };
  }

  String get year {
    if (releaseDate == null || releaseDate!.isEmpty) {
      return 'N/A';
    }
    return releaseDate!
        .split('-')
        .first; // định dạng ngày tháng năm yyyy-MM-dd, split tách chuỗi và lấy phần tử đầu tiên là năm
  }

  double get rating {
    return voteAverage / 2; // Chuyển đổi thang điểm từ 10 sang 5
  }

  String get formatterVoteAverage {
    return voteAverage.toStringAsFixed(1);
  }

  @override
  List<Object?> get props => [
    id,
    title,
    originalTitle,
    overview,
    posterPath,
    backdropPath,
    voteAverage,
    voteCount,
    releaseDate,
    genreIds,
    adult,
    originalLanguage,
    popularity,
    isTVShow,
    mediaType,
  ];
}
