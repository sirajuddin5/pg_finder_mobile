import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/discovery/bloc/discovery_bloc.dart';
import 'package:mobile/features/discovery/bloc/discovery_event.dart';
import 'package:mobile/features/discovery/bloc/discovery_state.dart';
import 'package:mobile/features/discovery/models/property_summary_model.dart';
import 'package:mobile/features/discovery/models/search_criteria_model.dart';
import 'package:mobile/features/discovery/repositories/discovery_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockDiscoveryRepository extends Mock implements DiscoveryRepository {}

void main() {
  late MockDiscoveryRepository mockDiscoveryRepository;
  late DiscoveryBloc discoveryBloc;

  const testProperty = PropertySummaryModel(
    id: 1,
    title: 'Emerald Residency PG',
    propertyType: 'PG_BOYS',
    addressLine: '123 Indiranagar',
    city: 'Bengaluru',
    latitude: 12.9784,
    longitude: 77.6408,
    distanceKm: 2.1,
    minMonthlyRent: 9500.0,
    totalVacantBeds: 4,
    foodAvailable: true,
    foodType: 'BOTH',
  );

  setUpAll(() {
    registerFallbackValue(const SearchCriteriaModel());
  });

  setUp(() {
    mockDiscoveryRepository = MockDiscoveryRepository();
    discoveryBloc = DiscoveryBloc(discoveryRepository: mockDiscoveryRepository);
  });

  tearDown(() {
    discoveryBloc.close();
  });

  group('DiscoveryBloc Unit Tests', () {
    test('initial state is DiscoveryInitial', () {
      expect(discoveryBloc.state, equals(DiscoveryInitial()));
    });

    blocTest<DiscoveryBloc, DiscoveryState>(
      'emits [DiscoveryLoading, DiscoveryLoaded] when SearchPropertiesRequested succeeds',
      build: () {
        when(() => mockDiscoveryRepository.searchProperties(any()))
            .thenAnswer((_) async => {'properties': [testProperty], 'totalElements': 1});
        return discoveryBloc;
      },
      act: (bloc) => bloc.add(const SearchPropertiesRequested(criteria: SearchCriteriaModel())),
      expect: () => [
        DiscoveryLoading(),
        const DiscoveryLoaded(
          properties: [testProperty],
          totalElements: 1,
          currentCriteria: SearchCriteriaModel(),
        ),
      ],
    );

    blocTest<DiscoveryBloc, DiscoveryState>(
      'emits [DiscoveryLoading, DiscoveryError] when SearchPropertiesRequested fails',
      build: () {
        when(() => mockDiscoveryRepository.searchProperties(any()))
            .thenThrow(Exception('Network error searching properties'));
        return discoveryBloc;
      },
      act: (bloc) => bloc.add(const SearchPropertiesRequested(criteria: SearchCriteriaModel())),
      expect: () => [
        DiscoveryLoading(),
        const DiscoveryError('Network error searching properties'),
      ],
    );
  });
}
