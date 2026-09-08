import 'package:equatable/equatable.dart';
import 'payment_order_model.dart';

class BookingModel extends Equatable {
  final int id;
  final String bookingReference;
  final int bedId;
  final String bedIdentifier;
  final String roomNumber;
  final String propertyTitle;
  final String checkInDate;
  final double tokenAmountPaid;
  final double monthlyRent;
  final double securityDeposit;
  final String status;
  final String? lockExpiresAt;
  final PaymentOrderModel? paymentOrder;

  const BookingModel({
    required this.id,
    required this.bookingReference,
    required this.bedId,
    required this.bedIdentifier,
    required this.roomNumber,
    required this.propertyTitle,
    required this.checkInDate,
    required this.tokenAmountPaid,
    required this.monthlyRent,
    required this.securityDeposit,
    required this.status,
    this.lockExpiresAt,
    this.paymentOrder,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'] as int,
      bookingReference: json['bookingReference'] as String? ?? '',
      bedId: json['bedId'] as int? ?? 0,
      bedIdentifier: json['bedIdentifier'] as String? ?? '',
      roomNumber: json['roomNumber'] as String? ?? '',
      propertyTitle: json['propertyTitle'] as String? ?? '',
      checkInDate: json['checkInDate'] as String? ?? '',
      tokenAmountPaid: (json['tokenAmountPaid'] as num?)?.toDouble() ?? 0.0,
      monthlyRent: (json['monthlyRent'] as num?)?.toDouble() ?? 0.0,
      securityDeposit: (json['securityDeposit'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] as String? ?? 'PENDING_PAYMENT',
      lockExpiresAt: json['lockExpiresAt'] as String?,
      paymentOrder: json['paymentOrder'] != null
          ? PaymentOrderModel.fromJson(json['paymentOrder'] as Map<String, dynamic>)
          : null,
    );
  }

  bool get isConfirmed => status == 'CONFIRMED' || status == 'ACTIVE_STAY';
  bool get isPendingPayment => status == 'PENDING_PAYMENT';
  bool get isCancelled => status == 'CANCELLED';

  @override
  List<Object?> get props => [
        id,
        bookingReference,
        bedId,
        bedIdentifier,
        roomNumber,
        propertyTitle,
        checkInDate,
        tokenAmountPaid,
        monthlyRent,
        securityDeposit,
        status,
        lockExpiresAt,
        paymentOrder,
      ];
}
