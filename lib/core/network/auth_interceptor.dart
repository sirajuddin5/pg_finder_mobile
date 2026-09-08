import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import 'token_storage.dart';

class AuthInterceptor extends QueuedInterceptor {
  final TokenStorage _tokenStorage;
  final Dio _dio;

  AuthInterceptor(this._tokenStorage, this._dio);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // Skip authorization header for public auth & search routes
    final isPublic = options.path.contains('/auth/login') ||
        options.path.contains('/auth/register') ||
        options.path.contains('/auth/refresh-token') ||
        options.path.contains('/properties/search');

    if (!isPublic) {
      final token = await _tokenStorage.getAccessToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }

    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401 && !err.requestOptions.path.contains('/auth/')) {
      final refreshToken = await _tokenStorage.getRefreshToken();
      if (refreshToken != null && refreshToken.isNotEmpty) {
        try {
          // Attempt token refresh with a raw Dio call to avoid cyclic interception
          final refreshResponse = await Dio(BaseOptions(baseUrl: ApiConstants.baseUrl)).post(
            ApiConstants.refreshToken,
            data: {'refreshToken': refreshToken},
          );

          if (refreshResponse.statusCode == 200 && refreshResponse.data != null) {
            final data = refreshResponse.data['data'];
            final newAccessToken = data['accessToken'] as String;
            final newRefreshToken = data['refreshToken'] as String;

            await _tokenStorage.saveTokens(
              accessToken: newAccessToken,
              refreshToken: newRefreshToken,
            );

            // Retry the failed request with the new access token
            final requestOptions = err.requestOptions;
            requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';
            final clonedResponse = await _dio.fetch(requestOptions);
            return handler.resolve(clonedResponse);
          }
        } catch (e) {
          // Token refresh failed - wipe credentials
          await _tokenStorage.clearTokens();
        }
      }
    }

    return handler.next(err);
  }
}
