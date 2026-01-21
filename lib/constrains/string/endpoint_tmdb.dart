import 'package:movie_app/constrains/env/env.dart';

class EndpointTmdb {
  static int page = 1;
  static String get apiKey => Env.apiKey;
  static String get apiAccessToken => Env.apiAccessToken;
  static String get baseUrl => Env.baseUrl;
  static String get imageBaseUrl => Env.imageBaseUrl;
  static String get accountId => Env.accountId;
  static String get getPopularMovies =>
      '$baseUrl/movie/popular?language=en-US&page=$page';
  static String get getTopRatedMovies =>
      '$baseUrl/movie/top_rated?language=en-US&page=$page';
  static String get getNowPlayingMovies =>
      '$baseUrl/movie/now_playing?language=en-US&page=$page';
  static String get getPopularTVShows =>
      '$baseUrl/tv/popular?language=en-US&page=$page';

  // account endpoint
  static String getAccountDetails(int accountId) =>
      '$baseUrl/account/$accountId';
}
