import 'package:flutter_dotenv/flutter_dotenv.dart';

String apiKey = dotenv.env['API_KEY'] ?? '';
String apiAccessToken = dotenv.env['API_ACCESS_TOKEN'] ?? '';
