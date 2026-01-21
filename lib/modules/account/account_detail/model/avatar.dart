class Avatar {
  final Gravatar? gravatar;
  final TmdbAvatar? tmdb;

  Avatar({required this.gravatar, required this.tmdb});
  factory Avatar.fromJson(Map<String, dynamic> json) {
    return Avatar(
      gravatar: json['gravatar'] != null
          ? Gravatar.fromJson(json['gravatar'])
          : null,
      tmdb: json['tmdb'] != null ? TmdbAvatar.fromJson(json['tmdb']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {'gravatar': gravatar?.toJson(), 'tmdb': tmdb?.toJson()};
  }
}

class TmdbAvatar {
  final String? avatarPath;
  TmdbAvatar({required this.avatarPath});
  factory TmdbAvatar.fromJson(Map<String, dynamic> json) {
    return TmdbAvatar(avatarPath: json['avatar_path'] ?? "");
  }
  Map<String, dynamic> toJson() {
    return {'avatar_path': avatarPath};
  }
}

class Gravatar {
  final String? hash;
  Gravatar({required this.hash});
  factory Gravatar.fromJson(Map<String, dynamic> json) {
    return Gravatar(hash: json['hash'] ?? "");
  }
  Map<String, dynamic> toJson() {
    return {'hash': hash};
  }
}
