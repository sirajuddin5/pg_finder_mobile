import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import 'auth_interceptor.dart';
import 'logging_interceptor.dart';
import 'token_storage.dart';

class DioClient {
  static final DioClient _instance = DioClient._internal();
  factory DioClient() => _instance;

  late final Dio dio;

  DioClient._internal() {
    dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.addAll([
      AuthInterceptor(TokenStorage(), dio),
      LoggingInterceptor(),
    ]);
  }
}
