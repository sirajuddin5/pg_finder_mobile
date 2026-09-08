import 'package:dio/dio.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/network/dio_client.dart';
import '../../booking/models/booking_model.dart';
import '../models/complaint_model.dart';
import '../models/invoice_model.dart';

class TenantPortalRepository {
  final Dio _dio;

  TenantPortalRepository({Dio? dio}) : _dio = dio ?? DioClient().dio;

  Future<List<BookingModel>> getMyStays() async {
    try {
      final response = await _dio.get(ApiConstants.myBookings);
      final data = response.data['data'] as List<dynamic>?;
      return data?.map((e) => BookingModel.fromJson(e as Map<String, dynamic>)).toList() ?? [];
    } on DioException catch (e) {
      final message = e.response?.data?['message'] ?? 'Failed to load active stay';
      throw Exception(message);
    }
  }

  Future<List<InvoiceModel>> getMyInvoices() async {
    try {
      final response = await _dio.get(ApiConstants.myInvoices);
      final data = response.data['data'] as List<dynamic>?;
      return data?.map((e) => InvoiceModel.fromJson(e as Map<String, dynamic>)).toList() ?? [];
    } on DioException catch (e) {
      final message = e.response?.data?['message'] ?? 'Failed to load invoices';
      throw Exception(message);
    }
  }

  Future<InvoiceModel> payInvoice({
    required int invoiceId,
    required String orderId,
    required String paymentId,
    required String signature,
  }) async {
    try {
      final response = await _dio.post(
        '${ApiConstants.initiateInvoicePayment}/$invoiceId/pay',
        data: {
          'razorpayOrderId': orderId,
          'razorpayPaymentId': paymentId,
          'razorpaySignature': signature,
        },
      );
      final data = response.data['data'];
      return InvoiceModel.fromJson(data);
    } on DioException catch (e) {
      final message = e.response?.data?['message'] ?? 'Failed to settle invoice';
      throw Exception(message);
    }
  }

  Future<List<ComplaintModel>> getMyComplaints() async {
    try {
      final response = await _dio.get(ApiConstants.myComplaints);
      final data = response.data['data'] as List<dynamic>?;
      return data?.map((e) => ComplaintModel.fromJson(e as Map<String, dynamic>)).toList() ?? [];
    } on DioException catch (e) {
      final message = e.response?.data?['message'] ?? 'Failed to load complaints';
      throw Exception(message);
    }
  }

  Future<ComplaintModel> createComplaint({
    required int propertyId,
    required String category,
    required String title,
    required String description,
    String? attachmentUrl,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.complaints,
        data: {
          'propertyId': propertyId,
          'category': category,
          'title': title,
          'description': description,
          'attachmentUrl': attachmentUrl,
        },
      );
      final data = response.data['data'];
      return ComplaintModel.fromJson(data);
    } on DioException catch (e) {
      final message = e.response?.data?['message'] ?? 'Failed to submit complaint';
      throw Exception(message);
    }
  }
}
