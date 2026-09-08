import 'package:dio/dio.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/network/dio_client.dart';
import '../../discovery/models/property_summary_model.dart';
import '../../property/models/property_detail_model.dart';
import '../../property/models/room_model.dart';
import '../../tenant_portal/models/complaint_model.dart';
import '../../property/models/bed_model.dart';
import '../../tenant_portal/models/invoice_model.dart';
import '../models/create_property_dto.dart';
import '../models/create_room_dto.dart';

class OwnerRepository {
  final Dio _dio;

  OwnerRepository({Dio? dio}) : _dio = dio ?? DioClient().dio;

  Future<List<PropertySummaryModel>> getMyProperties() async {
    try {
      final response = await _dio.get(ApiConstants.myProperties);
      final data = response.data['data'] as List<dynamic>?;
      return data
              ?.map((e) => PropertySummaryModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [];
    } on DioException catch (e) {
      final message = e.response?.data?['message'] ?? 'Failed to load owner properties';
      throw Exception(message);
    }
  }

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

  Future<PropertyDetailModel> createProperty(CreatePropertyDto dto) async {
    try {
      final response = await _dio.post(
        ApiConstants.createProperty,
        data: dto.toJson(),
      );
      final data = response.data['data'];
      return PropertyDetailModel.fromJson(data);
    } on DioException catch (e) {
      final message = e.response?.data?['message'] ?? 'Failed to create PG property';
      throw Exception(message);
    }
  }

  Future<RoomModel> createRoom(int propertyId, CreateRoomDto dto) async {
    try {
      final response = await _dio.post(
        '${ApiConstants.createProperty}/$propertyId/rooms',
        data: dto.toJson(),
      );
      final data = response.data['data'];
      return RoomModel.fromJson(data);
    } on DioException catch (e) {
      final message = e.response?.data?['message'] ?? 'Failed to add room';
      throw Exception(message);
    }
  }

  Future<BedModel> updateBedStatus(int bedId, String status) async {
    try {
      final response = await _dio.patch(
        '${ApiConstants.updateBedStatus}/$bedId/status',
        data: {'status': status},
      );
      final data = response.data['data'];
      return BedModel.fromJson(data);
    } on DioException catch (e) {
      final message = e.response?.data?['message'] ?? 'Failed to update bed status';
      throw Exception(message);
    }
  }

  Future<List<ComplaintModel>> getOwnerComplaints() async {
    try {
      final response = await _dio.get(ApiConstants.complaints);
      final data = response.data['data'];
      List<dynamic> list = [];
      if (data is Map && data.containsKey('content')) {
        list = data['content'] as List<dynamic>;
      } else if (data is List) {
        list = data;
      }
      return list.map((e) => ComplaintModel.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      final message = e.response?.data?['message'] ?? 'Failed to load complaints';
      throw Exception(message);
    }
  }

  Future<ComplaintModel> updateComplaintStatus(
    int complaintId,
    String status, {
    String? resolutionNotes,
  }) async {
    try {
      final payload = <String, dynamic>{'status': status};
      if (resolutionNotes != null && resolutionNotes.isNotEmpty) {
        payload['resolutionNotes'] = resolutionNotes;
      }
      final response = await _dio.patch(
        '${ApiConstants.complaints}/$complaintId/status',
        data: payload,
      );
      final data = response.data['data'];
      return ComplaintModel.fromJson(data);
    } on DioException catch (e) {
      final message = e.response?.data?['message'] ?? 'Failed to update complaint';
      throw Exception(message);
    }
  }

  Future<List<InvoiceModel>> getPropertyInvoices(int propertyId) async {
    try {
      final response = await _dio.get('${ApiConstants.propertyInvoices}/$propertyId');
      final data = response.data['data'] as List<dynamic>?;
      return data
              ?.map((e) => InvoiceModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [];
    } on DioException catch (e) {
      final message = e.response?.data?['message'] ?? 'Failed to load property invoices';
      throw Exception(message);
    }
  }
}
