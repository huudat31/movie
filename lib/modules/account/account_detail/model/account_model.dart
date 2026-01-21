import 'package:movie_app/modules/account/account_detail/model/avatar.dart';

class AccountModel {
  final Avatar? avatar;
  final int id;
  final String iso_639_1;
  final String iso_3166_1;
  final String name;
  final bool includeAdult;
  final String username;

  AccountModel({
    this.avatar,
    required this.id,
    required this.iso_639_1,
    required this.iso_3166_1,
    required this.name,
    required this.includeAdult,
    required this.username,
  });
  factory AccountModel.fromJson(Map<String, dynamic> json) {
    return AccountModel(
      id: json['id'] ?? 0,
      iso_639_1: json['iso_639_1'] ?? "",
      iso_3166_1: json['iso_3166_1'] ?? "",
      name: json['name'] ?? "",
      includeAdult: json['include_adult'] ?? false,
      username: json['username'] ?? "",
      avatar: json['avatar'] != null ? Avatar.fromJson(json['avatar']) : null,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'iso_639_1': iso_639_1,
      'iso_3166_1': iso_3166_1,
      'name': name,
      'include_adult': includeAdult,
      'username': username,
      'avatar': avatar?.toJson(),
    };
  }
}
