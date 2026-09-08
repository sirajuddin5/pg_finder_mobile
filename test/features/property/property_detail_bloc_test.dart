import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/property/bloc/property_detail_bloc.dart';
import 'package:mobile/features/property/bloc/property_detail_event.dart';
import 'package:mobile/features/property/bloc/property_detail_state.dart';
import 'package:mobile/features/property/models/bed_model.dart';
import 'package:mobile/features/property/models/property_detail_model.dart';
import 'package:mobile/features/property/models/room_model.dart';
import 'package:mobile/features/property/repositories/property_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockPropertyRepository extends Mock implements PropertyRepository {}

void main() {
  late MockPropertyRepository mockPropertyRepository;
  late PropertyDetailBloc propertyDetailBloc;

  const testBed = BedModel(id: 1, bedIdentifier: '101-A', isAvailable: true, status: 'VACANT');
  const testRoom = RoomModel(
    id: 10,
    roomNumber: '101',
    floorNumber: 1,
    sharingType: 'SINGLE',
    baseRentMonthly: 12000.0,
    securityDeposit: 24000.0,
    hasAc: true,
    hasAttachedBathroom: true,
    hasBalcony: false,
    beds: [testBed],
  );

  const testProperty = PropertyDetailModel(
    id: 1,
    title: 'Emerald PG',
    description: 'Modern PG',
    propertyType: 'PG_BOYS',
    addressLine: '123 Indiranagar',
    city: 'Bengaluru',
    state: 'Karnataka',
    pincode: '560038',
    latitude: 12.9784,
    longitude: 77.6408,
    noticePeriodDays: 30,
    foodAvailable: true,
    foodType: 'BOTH',
    isVerified: true,
    rooms: [testRoom],
  );

  setUp(() {
    mockPropertyRepository = MockPropertyRepository();
    propertyDetailBloc = PropertyDetailBloc(propertyRepository: mockPropertyRepository);
  });

  tearDown(() {
    propertyDetailBloc.close();
  });

  group('PropertyDetailBloc Unit Tests', () {
    test('initial state is PropertyDetailInitial', () {
      expect(propertyDetailBloc.state, equals(PropertyDetailInitial()));
    });

    blocTest<PropertyDetailBloc, PropertyDetailState>(
      'emits [PropertyDetailLoading, PropertyDetailLoaded] when LoadPropertyDetailRequested succeeds',
      build: () {
        when(() => mockPropertyRepository.getPropertyDetails(1)).thenAnswer((_) async => testProperty);
        when(() => mockPropertyRepository.getPropertyRooms(1)).thenAnswer((_) async => [testRoom]);
        return propertyDetailBloc;
      },
      act: (bloc) => bloc.add(const LoadPropertyDetailRequested(1)),
      expect: () => [
        PropertyDetailLoading(),
        isA<PropertyDetailLoaded>()
            .having((s) => s.property.id, 'property.id', 1)
            .having((s) => s.selectedRoom?.roomNumber, 'selectedRoom.roomNumber', '101')
            .having((s) => s.selectedBed?.bedIdentifier, 'selectedBed.bedIdentifier', '101-A'),
      ],
    );
  });
}
