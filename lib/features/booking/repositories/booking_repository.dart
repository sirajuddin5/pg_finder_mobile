import 'package:dio/dio.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/network/dio_client.dart';
import '../models/booking_model.dart';

class BookingRepository {
  final Dio _dio;

  BookingRepository({Dio? dio}) : _dio = dio ?? DioClient().dio;

  Future<BookingModel> initiateBooking({
    required int bedId,
    required String checkInDate,
    required double tokenAmount,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.initiateBooking,
        data: {
          'bedId': bedId,
          'checkInDate': checkInDate,
          'tokenAmount': tokenAmount,
        },
      );

      final data = response.data['data'];
      return BookingModel.fromJson(data);
    } on DioException catch (e) {
      final message = e.response?.data?['message'] ?? 'Failed to reserve bed';
      throw Exception(message);
    }
  }

  Future<BookingModel> verifyPayment({
    required int bookingId,
    required String gatewayOrderId,
    required String gatewayPaymentId,
    required String gatewaySignature,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.verifyPayment,
        data: {
          'bookingId': bookingId,
          'gatewayOrderId': gatewayOrderId,
          'gatewayPaymentId': gatewayPaymentId,
          'gatewaySignature': gatewaySignature,
        },
      );

      final data = response.data['data'];
      return BookingModel.fromJson(data);
    } on DioException catch (e) {
      final message = e.response?.data?['message'] ?? 'Payment verification failed';
      throw Exception(message);
    }
  }

  Future<List<BookingModel>> getMyBookings() async {
    try {
      final response = await _dio.get(ApiConstants.myBookings);
      final data = response.data['data'] as List<dynamic>?;
      return data?.map((e) => BookingModel.fromJson(e as Map<String, dynamic>)).toList() ?? [];
    } on DioException catch (e) {
      final message = e.response?.data?['message'] ?? 'Failed to load bookings';
      throw Exception(message);
    }
  }
}
