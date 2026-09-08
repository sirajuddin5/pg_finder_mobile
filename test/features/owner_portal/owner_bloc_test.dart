import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/discovery/models/property_summary_model.dart';
import 'package:mobile/features/owner_portal/bloc/owner_bloc.dart';
import 'package:mobile/features/owner_portal/bloc/owner_event.dart';
import 'package:mobile/features/owner_portal/bloc/owner_state.dart';
import 'package:mobile/features/owner_portal/models/create_property_dto.dart';
import 'package:mobile/features/owner_portal/models/create_room_dto.dart';
import 'package:mobile/features/owner_portal/repositories/owner_repository.dart';
import 'package:mobile/features/property/models/property_detail_model.dart';
import 'package:mobile/features/property/models/room_model.dart';
import 'package:mobile/features/tenant_portal/models/complaint_model.dart';
import 'package:mocktail/mocktail.dart';

class MockOwnerRepository extends Mock implements OwnerRepository {}

void main() {
  late MockOwnerRepository mockOwnerRepository;
  late OwnerBloc ownerBloc;

  const testPropertySummary = PropertySummaryModel(
    id: 1,
    title: 'Sunrise Boys PG',
    propertyType: 'PG_BOYS',
    addressLine: '123 Main Road',
    city: 'Bengaluru',
    latitude: 12.9716,
    longitude: 77.5946,
    distanceKm: 0.0,
    minMonthlyRent: 8500.0,
    totalVacantBeds: 5,
    foodAvailable: true,
    foodType: 'BOTH',
  );

  const testPropertyDetail = PropertyDetailModel(
    id: 1,
    title: 'Sunrise Boys PG',
    description: 'Clean and spacious PG with food & wifi',
    propertyType: 'PG_BOYS',
    addressLine: '123 Main Road',
    city: 'Bengaluru',
    state: 'Karnataka',
    pincode: '560001',
    latitude: 12.9716,
    longitude: 77.5946,
    noticePeriodDays: 30,
    foodAvailable: true,
    foodType: 'BOTH',
    isVerified: true,
  );

  const testRoom = RoomModel(
    id: 10,
    roomNumber: '101',
    floorNumber: 1,
    sharingType: 'DOUBLE',
    baseRentMonthly: 8500.0,
    securityDeposit: 17000.0,
    hasAc: true,
    hasAttachedBathroom: true,
    hasBalcony: false,
    beds: [],
  );

  const testComplaint = ComplaintModel(
    id: 1,
    title: 'Wi-Fi not working',
    description: 'Wi-Fi router on 2nd floor is powered off',
    category: 'WIFI_INTERNET',
    status: 'OPEN',
    createdAt: '2026-09-08T10:00:00Z',
  );

  setUp(() {
    mockOwnerRepository = MockOwnerRepository();
    ownerBloc = OwnerBloc(ownerRepository: mockOwnerRepository);
  });

  tearDown(() {
    ownerBloc.close();
  });

  group('OwnerBloc Unit Tests', () {
    test('initial state is OwnerInitial', () {
      expect(ownerBloc.state, equals(OwnerInitial()));
    });

    blocTest<OwnerBloc, OwnerState>(
      'emits [OwnerLoading, OwnerDashboardLoaded] when LoadOwnerDashboardRequested succeeds',
      build: () {
        when(() => mockOwnerRepository.getMyProperties())
            .thenAnswer((_) async => [testPropertySummary]);
        when(() => mockOwnerRepository.getOwnerComplaints())
            .thenAnswer((_) async => [testComplaint]);
        return ownerBloc;
      },
      act: (bloc) => bloc.add(LoadOwnerDashboardRequested()),
      expect: () => [
        OwnerLoading(),
        OwnerDashboardLoaded(
          properties: const [testPropertySummary],
          complaints: const [testComplaint],
        ),
      ],
    );

    blocTest<OwnerBloc, OwnerState>(
      'emits [OwnerLoading, PropertyCreatedSuccess, OwnerLoading, OwnerDashboardLoaded] when CreatePropertySubmitted succeeds',
      build: () {
        const dto = CreatePropertyDto(
          title: 'Sunrise Boys PG',
          description: 'Clean and spacious PG',
          propertyType: 'PG_BOYS',
          addressLine: '123 Main Road',
          city: 'Bengaluru',
          state: 'Karnataka',
          pincode: '560001',
          latitude: 12.9716,
          longitude: 77.5946,
          noticePeriodDays: 30,
          gateClosingTime: '22:30:00',
          foodAvailable: true,
          foodType: 'BOTH',
          amenityIds: [1, 2, 3],
        );
        when(() => mockOwnerRepository.createProperty(dto))
            .thenAnswer((_) async => testPropertyDetail);
        when(() => mockOwnerRepository.getMyProperties())
            .thenAnswer((_) async => [testPropertySummary]);
        when(() => mockOwnerRepository.getOwnerComplaints())
            .thenAnswer((_) async => [testComplaint]);
        return ownerBloc;
      },
      act: (bloc) => bloc.add(const CreatePropertySubmitted(
        CreatePropertyDto(
          title: 'Sunrise Boys PG',
          description: 'Clean and spacious PG',
          propertyType: 'PG_BOYS',
          addressLine: '123 Main Road',
          city: 'Bengaluru',
          state: 'Karnataka',
          pincode: '560001',
          latitude: 12.9716,
          longitude: 77.5946,
          noticePeriodDays: 30,
          gateClosingTime: '22:30:00',
          foodAvailable: true,
          foodType: 'BOTH',
          amenityIds: [1, 2, 3],
        ),
      )),
      expect: () => [
        OwnerLoading(),
        const PropertyCreatedSuccess(testPropertyDetail),
        OwnerLoading(),
        OwnerDashboardLoaded(
          properties: const [testPropertySummary],
          complaints: const [testComplaint],
        ),
      ],
    );

    blocTest<OwnerBloc, OwnerState>(
      'emits [OwnerLoading, RoomCreatedSuccess, OwnerLoading, OwnerDashboardLoaded] when CreateRoomSubmitted succeeds',
      build: () {
        const dto = CreateRoomDto(
          roomNumber: '101',
          floorNumber: 1,
          sharingType: 'DOUBLE',
          baseRentMonthly: 8500.0,
          securityDeposit: 17000.0,
          hasAc: true,
          hasAttachedBathroom: true,
          hasBalcony: false,
          autoGenerateBeds: true,
        );
        when(() => mockOwnerRepository.createRoom(1, dto))
            .thenAnswer((_) async => testRoom);
        when(() => mockOwnerRepository.getMyProperties())
            .thenAnswer((_) async => [testPropertySummary]);
        when(() => mockOwnerRepository.getOwnerComplaints())
            .thenAnswer((_) async => [testComplaint]);
        return ownerBloc;
      },
      act: (bloc) => bloc.add(const CreateRoomSubmitted(
        propertyId: 1,
        dto: CreateRoomDto(
          roomNumber: '101',
          floorNumber: 1,
          sharingType: 'DOUBLE',
          baseRentMonthly: 8500.0,
          securityDeposit: 17000.0,
          hasAc: true,
          hasAttachedBathroom: true,
          hasBalcony: false,
          autoGenerateBeds: true,
        ),
      )),
      expect: () => [
        OwnerLoading(),
        const RoomCreatedSuccess(testRoom),
        OwnerLoading(),
        OwnerDashboardLoaded(
          properties: const [testPropertySummary],
          complaints: const [testComplaint],
        ),
      ],
    );

    blocTest<OwnerBloc, OwnerState>(
      'emits [OwnerLoading, OwnerDashboardLoaded] when UpdateComplaintStatusRequested succeeds',
      build: () {
        when(() => mockOwnerRepository.updateComplaintStatus(1, 'RESOLVED'))
            .thenAnswer((_) async => const ComplaintModel(
                  id: 1,
                  title: 'Wi-Fi not working',
                  description: 'Wi-Fi router on 2nd floor is powered off',
                  category: 'WIFI_INTERNET',
                  status: 'RESOLVED',
                  createdAt: '2026-09-08T10:00:00Z',
                ));
        when(() => mockOwnerRepository.getMyProperties())
            .thenAnswer((_) async => [testPropertySummary]);
        when(() => mockOwnerRepository.getOwnerComplaints())
            .thenAnswer((_) async => [testComplaint]);
        return ownerBloc;
      },
      act: (bloc) => bloc.add(const UpdateComplaintStatusRequested(
        complaintId: 1,
        status: 'RESOLVED',
      )),
      expect: () => [
        OwnerLoading(),
        OwnerDashboardLoaded(
          properties: const [testPropertySummary],
          complaints: const [testComplaint],
        ),
      ],
    );
  });
}