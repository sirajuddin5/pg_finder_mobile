import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/booking/bloc/booking_bloc.dart';
import 'package:mobile/features/booking/bloc/booking_event.dart';
import 'package:mobile/features/booking/bloc/booking_state.dart';
import 'package:mobile/features/booking/models/booking_model.dart';
import 'package:mobile/features/booking/repositories/booking_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockBookingRepository extends Mock implements BookingRepository {}

void main() {
  late MockBookingRepository mockBookingRepository;
  late BookingBloc bookingBloc;

  const testBooking = BookingModel(
    id: 10,
    bookingReference: 'BKG-TEST-100',
    bedId: 1,
    bedIdentifier: '101-A',
    roomNumber: '101',
    propertyTitle: 'Emerald Residency PG',
    checkInDate: '2026-09-10',
    tokenAmountPaid: 2000.0,
    monthlyRent: 10000.0,
    securityDeposit: 20000.0,
    status: 'PENDING_PAYMENT',
    lockExpiresAt: '2026-09-03T01:30:00Z',
  );

  const confirmedBooking = BookingModel(
    id: 10,
    bookingReference: 'BKG-TEST-100',
    bedId: 1,
    bedIdentifier: '101-A',
    roomNumber: '101',
    propertyTitle: 'Emerald Residency PG',
    checkInDate: '2026-09-10',
    tokenAmountPaid: 2000.0,
    monthlyRent: 10000.0,
    securityDeposit: 20000.0,
    status: 'CONFIRMED',
  );

  setUp(() {
    mockBookingRepository = MockBookingRepository();
    bookingBloc = BookingBloc(bookingRepository: mockBookingRepository);
  });

  tearDown(() {
    bookingBloc.close();
  });

  group('BookingBloc Unit Tests', () {
    test('initial state is BookingInitial', () {
      expect(bookingBloc.state, equals(BookingInitial()));
    });

    blocTest<BookingBloc, BookingState>(
      'emits [BookingInitiating, BedReservedPendingPayment] when InitiateBookingRequested succeeds',
      build: () {
        when(() => mockBookingRepository.initiateBooking(
              bedId: 1,
              checkInDate: '2026-09-10',
              tokenAmount: 2000.0,
            )).thenAnswer((_) async => testBooking);
        return bookingBloc;
      },
      act: (bloc) => bloc.add(const InitiateBookingRequested(
        bedId: 1,
        checkInDate: '2026-09-10',
        tokenAmount: 2000.0,
      )),
      expect: () => [
        BookingInitiating(),
        isA<BedReservedPendingPayment>()
            .having((s) => s.booking.id, 'booking.id', 10)
            .having((s) => s.booking.status, 'booking.status', 'PENDING_PAYMENT'),
      ],
    );

    blocTest<BookingBloc, BookingState>(
      'emits [PaymentVerifying, BookingConfirmedSuccess] when ConfirmPaymentRequested succeeds',
      build: () {
        when(() => mockBookingRepository.verifyPayment(
              bookingId: 10,
              gatewayOrderId: 'order_123',
              gatewayPaymentId: 'pay_123',
              gatewaySignature: 'sig_123',
            )).thenAnswer((_) async => confirmedBooking);
        return bookingBloc;
      },
      act: (bloc) => bloc.add(const ConfirmPaymentRequested(
        bookingId: 10,
        orderId: 'order_123',
        paymentId: 'pay_123',
        signature: 'sig_123',
      )),
      expect: () => [
        PaymentVerifying(),
        const BookingConfirmedSuccess(confirmedBooking),
      ],
    );
  });
}
