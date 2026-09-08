import 'package:equatable/equatable.dart';
import '../models/booking_model.dart';

abstract class BookingState extends Equatable {
  const BookingState();

  @override
  List<Object?> get props => [];
}

class BookingInitial extends BookingState {}

class BookingInitiating extends BookingState {}

class BedReservedPendingPayment extends BookingState {
  final BookingModel booking;
  final DateTime expiresAt;

  const BedReservedPendingPayment({
    required this.booking,
    required this.expiresAt,
  });

  @override
  List<Object?> get props => [booking, expiresAt];
}

class PaymentVerifying extends BookingState {}

class BookingConfirmedSuccess extends BookingState {
  final BookingModel booking;

  const BookingConfirmedSuccess(this.booking);

  @override
  List<Object?> get props => [booking];
}

class BookingError extends BookingState {
  final String message;

  const BookingError(this.message);

  @override
  List<Object?> get props => [message];
}
