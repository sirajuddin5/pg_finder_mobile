import 'package:dio/dio.dart';
import '../utils/app_logger.dart';

class LoggingInterceptor extends Interceptor {
  final Map<String, int> _requestStartTimes = {};

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final requestId = '${options.method}_${options.uri}_${DateTime.now().microsecondsSinceEpoch}';
    options.extra['requestId'] = requestId;
    _requestStartTimes[requestId] = DateTime.now().millisecondsSinceEpoch;

    AppLogger.i(
      '--> ${options.method.toUpperCase()} ${options.uri}',
      tag: 'HTTP-REQ',
    );

    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final requestId = response.requestOptions.extra['requestId'] as String?;
    final startTime = requestId != null ? _requestStartTimes.remove(requestId) : null;
    final duration = startTime != null ? DateTime.now().millisecondsSinceEpoch - startTime : 0;

    AppLogger.i(
      '<-- ${response.statusCode} ${response.requestOptions.method.toUpperCase()} ${response.requestOptions.uri} (${duration}ms)',
      tag: 'HTTP-RES',
    );

    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final requestId = err.requestOptions.extra['requestId'] as String?;
    final startTime = requestId != null ? _requestStartTimes.remove(requestId) : null;
    final duration = startTime != null ? DateTime.now().millisecondsSinceEpoch - startTime : 0;

    final statusCode = err.response?.statusCode ?? 'NETWORK_ERROR';
    final errorMsg = err.response?.data?['message'] ?? err.message ?? 'Unknown error';

    AppLogger.e(
      '<-- ERROR [$statusCode] ${err.requestOptions.method.toUpperCase()} ${err.requestOptions.uri} (${duration}ms): $errorMsg',
      tag: 'HTTP-ERR',
    );

    super.onError(err, handler);
  }
}