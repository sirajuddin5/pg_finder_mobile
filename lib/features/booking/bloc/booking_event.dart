import 'package:equatable/equatable.dart';

abstract class BookingEvent extends Equatable {
  const BookingEvent();

  @override
  List<Object?> get props => [];
}

class InitiateBookingRequested extends BookingEvent {
  final int bedId;
  final String checkInDate;
  final double tokenAmount;

  const InitiateBookingRequested({
    required this.bedId,
    required this.checkInDate,
    required this.tokenAmount,
  });

  @override
  List<Object?> get props => [bedId, checkInDate, tokenAmount];
}

class ConfirmPaymentRequested extends BookingEvent {
  final int bookingId;
  final String orderId;
  final String paymentId;
  final String signature;

  const ConfirmPaymentRequested({
    required this.bookingId,
    required this.orderId,
    required this.paymentId,
    required this.signature,
  });

  @override
  List<Object?> get props => [bookingId, orderId, paymentId, signature];
}

class ResetBookingFlow extends BookingEvent {}
