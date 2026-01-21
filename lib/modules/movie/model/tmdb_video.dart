import 'package:equatable/equatable.dart';

class TMDBVideo extends Equatable {
  final String id;
  final String key;
  final String name;
  final String site;
  final int size;
  final String type;
  final bool official;
  final String publishedAt;

  const TMDBVideo({
    required this.id,
    required this.key,
    required this.name,
    this.site = 'YouTube',
    this.size = 1080,
    this.type = 'Trailer',
    this.official = false,
    required this.publishedAt,
  });

  factory TMDBVideo.fromJson(Map<String, dynamic> json) {
    return TMDBVideo(
      id: json['id'] ?? '',
      key: json['key'] ?? '',
      name: json['name'] ?? 'Unknown',
      site: json['site'] ?? 'YouTube',
      size: json['size'] ?? 1080,
      type: json['type'] ?? 'Trailer',
      official: json['official'] ?? false,
      publishedAt: json['published_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'key': key,
      'name': name,
      'site': site,
      'size': size,
      'type': type,
      'official': official,
      'published_at': publishedAt,
    };
  }

  // Get YouTube URL
  String get youtubeUrl => 'https://www.youtube.com/watch?v=$key';

  // Get YouTube embed URL
  String get youtubeEmbedUrl => 'https://www.youtube.com/embed/$key';

  // Get thumbnail URL
  String get thumbnailUrl => 'https://img.youtube.com/vi/$key/hqdefault.jpg';

  // Check if it's a trailer
  bool get isTrailer => type.toLowerCase().contains('trailer');

  // Check if it's a teaser
  bool get isTeaser => type.toLowerCase().contains('teaser');

  @override
  List<Object?> get props => [id, key, name, site, type, official];
}
