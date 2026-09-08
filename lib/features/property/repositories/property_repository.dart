import 'package:dio/dio.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/network/dio_client.dart';
import '../models/property_detail_model.dart';
import '../models/room_model.dart';

class PropertyRepository {
  final Dio _dio;

  PropertyRepository({Dio? dio}) : _dio = dio ?? DioClient().dio;

  Future<PropertyDetailModel> getPropertyDetails(int propertyId) async {
    try {
      final response = await _dio.get('${ApiConstants.propertyDetails}/$propertyId');
      final data = response.data['data'];
      return PropertyDetailModel.fromJson(data);
    } on DioException catch (e) {
      final message = e.response?.data?['message'] ?? 'Failed to load property details';
      throw Exception(message);
    }
  }

  Future<List<RoomModel>> getPropertyRooms(int propertyId) async {
    try {
      final response = await _dio.get('${ApiConstants.propertyDetails}/$propertyId/rooms');
      final data = response.data['data'] as List<dynamic>?;
      return data?.map((e) => RoomModel.fromJson(e as Map<String, dynamic>)).toList() ?? [];
    } on DioException catch (e) {
      final message = e.response?.data?['message'] ?? 'Failed to load rooms and beds';
      throw Exception(message);
    }
  }
}
