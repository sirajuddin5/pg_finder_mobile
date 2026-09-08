import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/admin_portal/bloc/admin_bloc.dart';
import 'package:mobile/features/admin_portal/bloc/admin_event.dart';
import 'package:mobile/features/admin_portal/bloc/admin_state.dart';
import 'package:mobile/features/admin_portal/models/admin_stats_model.dart';
import 'package:mobile/features/admin_portal/models/admin_user_model.dart';
import 'package:mobile/features/admin_portal/models/kyc_document_model.dart';
import 'package:mobile/features/admin_portal/repositories/admin_repository.dart';
import 'package:mobile/features/discovery/models/property_summary_model.dart';
import 'package:mobile/features/property/models/property_detail_model.dart';
import 'package:mobile/features/tenant_portal/models/complaint_model.dart';
import 'package:mocktail/mocktail.dart';

class MockAdminRepository extends Mock implements AdminRepository {}

void main() {
  late MockAdminRepository mockAdminRepository;
  late AdminBloc adminBloc;

  const testStats = AdminStatsModel(
    totalProperties: 10,
    pendingProperties: 2,
    totalUsers: 45,
    totalBeds: 100,
    occupiedBeds: 80,
    openComplaints: 3,
    totalRevenue: 500000.0,
  );

  const testPendingProperty = PropertySummaryModel(
    id: 1,
    title: 'Elite Boys PG',
    propertyType: 'PG_BOYS',
    addressLine: 'Plot 45, Sector 62',
    city: 'Noida',
    latitude: 28.6280,
    longitude: 77.3649,
    distanceKm: 0.0,
    minMonthlyRent: 9000.0,
    totalVacantBeds: 4,
    foodAvailable: true,
    foodType: 'VEG_ONLY',
  );

  const testVerifiedProperty = PropertyDetailModel(
    id: 1,
    title: 'Elite Boys PG',
    description: 'Premier PG accommodation',
    propertyType: 'PG_BOYS',
    addressLine: 'Plot 45, Sector 62',
    city: 'Noida',
    state: 'Uttar Pradesh',
    pincode: '201301',
    latitude: 28.6280,
    longitude: 77.3649,
    noticePeriodDays: 30,
    foodAvailable: true,
    foodType: 'VEG_ONLY',
    isVerified: true,
  );

  final testKycDoc = KycDocumentModel(
    id: 1,
    userId: 2,
    userName: 'Rahul Verma',
    userEmail: 'rahul@gmail.com',
    userRole: 'TENANT',
    documentType: 'AADHAAR',
    documentNumber: '1234-5678-9012',
    documentUrl: 'https://example.com/doc.jpg',
    status: 'PENDING',
    createdAt: DateTime(2026, 9, 8),
  );

  const testComplaint = ComplaintModel(
    id: 1,
    title: 'Tap leaking',
    description: 'Bathroom tap is dripping',
    category: 'PLUMBING',
    status: 'OPEN',
    createdAt: '2026-09-08T10:00:00Z',
  );

  final testUser = AdminUserModel(
    id: 1,
    fullName: 'Manisha Sharma',
    email: 'manisha@pgfinder.com',
    phoneNumber: '+91 9876543210',
    role: 'OWNER',
    active: true,
    createdAt: DateTime(2026, 8, 1),
  );

  setUp(() {
    mockAdminRepository = MockAdminRepository();
    adminBloc = AdminBloc(adminRepository: mockAdminRepository);
  });

  tearDown(() {
    adminBloc.close();
  });

  group('AdminBloc Unit Tests', () {
    test('initial state is AdminInitial', () {
      expect(adminBloc.state, equals(AdminInitial()));
    });

    blocTest<AdminBloc, AdminState>(
      'emits [AdminLoading, AdminDashboardLoaded] when FetchAdminDashboardRequested succeeds',
      build: () {
        when(() => mockAdminRepository.getAdminStats())
            .thenAnswer((_) async => testStats);
        return adminBloc;
      },
      act: (bloc) => bloc.add(FetchAdminDashboardRequested()),
      expect: () => [
        AdminLoading(),
        const AdminDashboardLoaded(testStats),
      ],
    );

    blocTest<AdminBloc, AdminState>(
      'emits [AdminLoading, PendingPropertiesLoaded] when FetchPendingPropertiesRequested succeeds',
      build: () {
        when(() => mockAdminRepository.getPendingProperties())
            .thenAnswer((_) async => [testPendingProperty]);
        return adminBloc;
      },
      act: (bloc) => bloc.add(FetchPendingPropertiesRequested()),
      expect: () => [
        AdminLoading(),
        const PendingPropertiesLoaded([testPendingProperty]),
      ],
    );

    blocTest<AdminBloc, AdminState>(
      'emits [AdminLoading, PropertyVerifiedSuccess, PendingPropertiesLoaded] when VerifyPropertySubmitted succeeds',
      build: () {
        when(() => mockAdminRepository.verifyProperty(1, true, 'Approved'))
            .thenAnswer((_) async => testVerifiedProperty);
        when(() => mockAdminRepository.getPendingProperties())
            .thenAnswer((_) async => []);
        return adminBloc;
      },
      act: (bloc) => bloc.add(const VerifyPropertySubmitted(
        propertyId: 1,
        verified: true,
        remarks: 'Approved',
      )),
      expect: () => [
        AdminLoading(),
        const PropertyVerifiedSuccess(
          property: testVerifiedProperty,
          message: 'Property "Elite Boys PG" approved successfully!',
        ),
        const PendingPropertiesLoaded([]),
      ],
    );

    blocTest<AdminBloc, AdminState>(
      'emits [AdminLoading, PendingKycLoaded] when FetchPendingKycRequested succeeds',
      build: () {
        when(() => mockAdminRepository.getPendingKycDocuments())
            .thenAnswer((_) async => [testKycDoc]);
        return adminBloc;
      },
      act: (bloc) => bloc.add(FetchPendingKycRequested()),
      expect: () => [
        AdminLoading(),
        PendingKycLoaded([testKycDoc]),
      ],
    );

    blocTest<AdminBloc, AdminState>(
      'emits [AdminLoading, MonthlyInvoicingSuccess] when TriggerMonthlyInvoicingSubmitted succeeds',
      build: () {
        final date = DateTime(2026, 9, 1);
        when(() => mockAdminRepository.generateMonthlyInvoices(date))
            .thenAnswer((_) async => {'invoicesGenerated': 15});
        return adminBloc;
      },
      act: (bloc) =>
          bloc.add(TriggerMonthlyInvoicingSubmitted(DateTime(2026, 9, 1))),
      expect: () => [
        AdminLoading(),
        MonthlyInvoicingSuccess(
          billingMonth: DateTime(2026, 9, 1),
          invoicesGenerated: 15,
          message: 'Generated 15 rent invoices successfully.',
        ),
      ],
    );

    blocTest<AdminBloc, AdminState>(
      'emits [AdminLoading, AllComplaintsLoaded] when FetchAllComplaintsRequested succeeds',
      build: () {
        when(() => mockAdminRepository.getAllComplaints())
            .thenAnswer((_) async => [testComplaint]);
        return adminBloc;
      },
      act: (bloc) => bloc.add(FetchAllComplaintsRequested()),
      expect: () => [
        AdminLoading(),
        const AllComplaintsLoaded([testComplaint]),
      ],
    );

    blocTest<AdminBloc, AdminState>(
      'emits [AdminLoading, UsersLoaded] when FetchUsersRequested succeeds',
      build: () {
        when(() => mockAdminRepository.getUsers())
            .thenAnswer((_) async => [testUser]);
        return adminBloc;
      },
      act: (bloc) => bloc.add(FetchUsersRequested()),
      expect: () => [
        AdminLoading(),
        UsersLoaded([testUser]),
      ],
    );
  });
}
