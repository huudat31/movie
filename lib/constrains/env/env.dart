import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  static late String apiKey;
  static late String apiAccessToken;
  static late String baseUrl;
  static late String imageBaseUrl;
  static late String accountId;

  static Future<void> load() async {
    await dotenv.load(fileName: "assets/.env");
    apiKey = dotenv.env['API_KEY'] ?? '';
    apiAccessToken = dotenv.env['API_ACCESS_TOKEN'] ?? '';
    baseUrl = dotenv.env['BASE_URL'] ?? '';
    imageBaseUrl = dotenv.env['IMAGE_BASE_URL'] ?? '';
    accountId = dotenv.env['ACCOUNT_ID'] ?? '';
  }
}
