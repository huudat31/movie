import 'package:equatable/equatable.dart';

/// Represents a cast or crew member in movie/TV credits
class TMDBCredit extends Equatable {
  final int id;
  final String name;
  final String? profilePath;
  final String? character; // For cast
  final String? job; // For crew
  final String? department; // For crew (e.g., Directing, Writing)
  final int? order; // For cast ordering
  final double? popularity;
  final String? knownForDepartment;
  final bool? adult;
  final int? gender;
  final String? creditId;

  const TMDBCredit({
    required this.id,
    required this.name,
    this.profilePath,
    this.character,
    this.job,
    this.department,
    this.order,
    this.popularity,
    this.knownForDepartment,
    this.adult,
    this.gender,
    this.creditId,
  });

  factory TMDBCredit.fromJson(Map<String, dynamic> json, {bool isCast = true}) {
    return TMDBCredit(
      id: json['id'] ?? 0,
      name: json['name'] ?? json['original_name'] ?? 'Unknown',
      profilePath: json['profile_path'],
      character: json['character'],
      job: json['job'],
      department: json['department'],
      order: json['order'],
      popularity: (json['popularity'] ?? 0).toDouble(),
      knownForDepartment: json['known_for_department'],
      adult: json['adult'],
      gender: json['gender'],
      creditId: json['credit_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'profile_path': profilePath,
      'character': character,
      'job': job,
      'department': department,
      'order': order,
      'popularity': popularity,
      'known_for_department': knownForDepartment,
      'adult': adult,
      'gender': gender,
      'credit_id': creditId,
    };
  }

  @override
  List<Object?> get props => [
    id,
    name,
    profilePath,
    character,
    job,
    department,
    order,
    creditId,
  ];
}

/// Container for movie/TV credits (cast and crew)
class TMDBCredits extends Equatable {
  final List<TMDBCredit> cast;
  final List<TMDBCredit> crew;

  const TMDBCredits({required this.cast, required this.crew});

  factory TMDBCredits.fromJson(Map<String, dynamic> json) {
    return TMDBCredits(
      cast:
          (json['cast'] as List<dynamic>?)
              ?.map((e) => TMDBCredit.fromJson(e, isCast: true))
              .toList() ??
          [],
      crew:
          (json['crew'] as List<dynamic>?)
              ?.map((e) => TMDBCredit.fromJson(e, isCast: false))
              .toList() ??
          [],
    );
  }

  /// Get director(s) from crew
  List<TMDBCredit> get directors =>
      crew.where((c) => c.job?.toLowerCase() == 'director').toList();

  /// Get writers from crew
  List<TMDBCredit> get writers => crew
      .where(
        (c) =>
            c.department?.toLowerCase() == 'writing' ||
            c.job?.toLowerCase() == 'screenplay' ||
            c.job?.toLowerCase() == 'writer',
      )
      .toList();

  /// Get top billed cast (first 10)
  List<TMDBCredit> get topCast => cast.take(10).toList();

  @override
  List<Object?> get props => [cast, crew];
}
