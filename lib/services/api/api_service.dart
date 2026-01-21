import 'package:dio/dio.dart';
import 'package:movie_app/constrains/env/env.dart';

class ApiService {
  static Dio createDio() {
    final _dio = Dio(
      BaseOptions(
        baseUrl: Env.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        validateStatus: (status) {
          return status != null && status >= 200 && status < 300;
        },
      ),
    );
    _dio.interceptors.add(
      LogInterceptor(requestBody: true, responseBody: true, error: true),
    );
    return _dio;
  }
}
