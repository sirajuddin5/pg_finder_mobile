import 'package:flutter_bloc/flutter_bloc.dart';
import '../repositories/booking_repository.dart';
import 'booking_event.dart';
import 'booking_state.dart';

class BookingBloc extends Bloc<BookingEvent, BookingState> {
  final BookingRepository _bookingRepository;

  BookingBloc({required BookingRepository bookingRepository})
      : _bookingRepository = bookingRepository,
        super(BookingInitial()) {
    on<InitiateBookingRequested>(_onInitiateBooking);
    on<ConfirmPaymentRequested>(_onConfirmPayment);
    on<ResetBookingFlow>(_onResetBookingFlow);
  }

  Future<void> _onInitiateBooking(
    InitiateBookingRequested event,
    Emitter<BookingState> emit,
  ) async {
    emit(BookingInitiating());
    try {
      final booking = await _bookingRepository.initiateBooking(
        bedId: event.bedId,
        checkInDate: event.checkInDate,
        tokenAmount: event.tokenAmount,
      );

      final expiresAt = booking.lockExpiresAt != null
          ? DateTime.tryParse(booking.lockExpiresAt!) ?? DateTime.now().add(const Duration(minutes: 15))
          : DateTime.now().add(const Duration(minutes: 15));

      emit(BedReservedPendingPayment(
        booking: booking,
        expiresAt: expiresAt,
      ));
    } catch (e) {
      emit(BookingError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onConfirmPayment(
    ConfirmPaymentRequested event,
    Emitter<BookingState> emit,
  ) async {
    emit(PaymentVerifying());
    try {
      final confirmed = await _bookingRepository.verifyPayment(
        bookingId: event.bookingId,
        gatewayOrderId: event.orderId,
        gatewayPaymentId: event.paymentId,
        gatewaySignature: event.signature,
      );
      emit(BookingConfirmedSuccess(confirmed));
    } catch (e) {
      emit(BookingError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  void _onResetBookingFlow(
    ResetBookingFlow event,
    Emitter<BookingState> emit,
  ) {
    emit(BookingInitial());
  }
}
