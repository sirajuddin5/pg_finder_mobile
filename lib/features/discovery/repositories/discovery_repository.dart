import 'package:dio/dio.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/network/dio_client.dart';
import '../models/property_summary_model.dart';
import '../models/search_criteria_model.dart';

class DiscoveryRepository {
  final Dio _dio;

  DiscoveryRepository({Dio? dio}) : _dio = dio ?? DioClient().dio;

  Future<Map<String, dynamic>> searchProperties(SearchCriteriaModel criteria) async {
    try {
      final response = await _dio.get(
        ApiConstants.propertySearch,
        queryParameters: criteria.toQueryParameters(),
      );

      final data = response.data['data'];
      final content = (data['content'] as List<dynamic>?)
              ?.map((item) => PropertySummaryModel.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [];
      final totalElements = data['totalElements'] as int? ?? 0;

      return {
        'properties': content,
        'totalElements': totalElements,
      };
    } on DioException catch (e) {
      final message = e.response?.data?['message'] ?? 'Failed to search nearby properties';
      throw Exception(message);
    }
  }
}
