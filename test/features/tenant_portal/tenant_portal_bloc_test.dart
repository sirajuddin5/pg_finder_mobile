import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/booking/models/booking_model.dart';
import 'package:mobile/features/tenant_portal/bloc/tenant_portal_bloc.dart';
import 'package:mobile/features/tenant_portal/bloc/tenant_portal_event.dart';
import 'package:mobile/features/tenant_portal/bloc/tenant_portal_state.dart';
import 'package:mobile/features/tenant_portal/models/complaint_model.dart';
import 'package:mobile/features/tenant_portal/models/invoice_model.dart';
import 'package:mobile/features/tenant_portal/repositories/tenant_portal_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockTenantPortalRepository extends Mock implements TenantPortalRepository {}

void main() {
  late MockTenantPortalRepository mockTenantPortalRepository;
  late TenantPortalBloc tenantPortalBloc;

  const testStay = BookingModel(
    id: 1,
    bookingReference: 'BKG-101',
    bedId: 1,
    bedIdentifier: '101-A',
    roomNumber: '101',
    propertyTitle: 'Emerald Residency PG',
    checkInDate: '2026-08-01',
    tokenAmountPaid: 2000.0,
    monthlyRent: 10000.0,
    securityDeposit: 20000.0,
    status: 'ACTIVE_STAY',
  );

  const testInvoice = InvoiceModel(
    id: 5,
    invoiceNumber: 'INV-202609-0001',
    billingMonth: '2026-09-01',
    rentAmount: 10000.0,
    utilityCharges: 0.0,
    lateFee: 0.0,
    totalAmount: 10000.0,
    dueDate: '2026-09-05',
    status: 'UNPAID',
  );

  const testComplaint = ComplaintModel(
    id: 8,
    category: 'WIFI',
    title: 'Wi-Fi down',
    description: 'No internet on 1st floor',
    status: 'OPEN',
    createdAt: '2026-09-03T01:00:00Z',
  );

  setUp(() {
    mockTenantPortalRepository = MockTenantPortalRepository();
    tenantPortalBloc = TenantPortalBloc(tenantPortalRepository: mockTenantPortalRepository);
  });

  tearDown(() {
    tenantPortalBloc.close();
  });

  group('TenantPortalBloc Unit Tests', () {
    test('initial state is TenantPortalInitial', () {
      expect(tenantPortalBloc.state, equals(TenantPortalInitial()));
    });

    blocTest<TenantPortalBloc, TenantPortalState>(
      'emits [TenantPortalLoading, TenantDashboardLoaded] when LoadTenantDashboardRequested succeeds',
      build: () {
        when(() => mockTenantPortalRepository.getMyStays()).thenAnswer((_) async => [testStay]);
        when(() => mockTenantPortalRepository.getMyInvoices()).thenAnswer((_) async => [testInvoice]);
        when(() => mockTenantPortalRepository.getMyComplaints()).thenAnswer((_) async => [testComplaint]);
        return tenantPortalBloc;
      },
      act: (bloc) => bloc.add(LoadTenantDashboardRequested()),
      expect: () => [
        TenantPortalLoading(),
        const TenantDashboardLoaded(
          stays: [testStay],
          invoices: [testInvoice],
          complaints: [testComplaint],
        ),
      ],
    );

    blocTest<TenantPortalBloc, TenantPortalState>(
      'emits [TenantPortalLoading, InvoicePaymentSuccess, TenantPortalLoading, TenantDashboardLoaded] when PayInvoiceRequested succeeds',
      build: () {
        when(() => mockTenantPortalRepository.payInvoice(
              invoiceId: 5,
              orderId: any(named: 'orderId'),
              paymentId: any(named: 'paymentId'),
              signature: any(named: 'signature'),
            )).thenAnswer((_) async => const InvoiceModel(
              id: 5,
              invoiceNumber: 'INV-202609-0001',
              billingMonth: '2026-09-01',
              rentAmount: 10000.0,
              utilityCharges: 0.0,
              lateFee: 0.0,
              totalAmount: 10000.0,
              dueDate: '2026-09-05',
              status: 'PAID',
            ));
        when(() => mockTenantPortalRepository.getMyStays()).thenAnswer((_) async => [testStay]);
        when(() => mockTenantPortalRepository.getMyInvoices()).thenAnswer((_) async => []);
        when(() => mockTenantPortalRepository.getMyComplaints()).thenAnswer((_) async => []);
        return tenantPortalBloc;
      },
      act: (bloc) => bloc.add(const PayInvoiceRequested(5)),
      expect: () => [
        TenantPortalLoading(),
        isA<InvoicePaymentSuccess>(),
        TenantPortalLoading(),
        const TenantDashboardLoaded(stays: [testStay], invoices: [], complaints: []),
      ],
    );
  });
}
