import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/search_criteria_model.dart';
import '../repositories/discovery_repository.dart';
import 'discovery_event.dart';
import 'discovery_state.dart';

class DiscoveryBloc extends Bloc<DiscoveryEvent, DiscoveryState> {
  final DiscoveryRepository _discoveryRepository;
  SearchCriteriaModel _currentCriteria = const SearchCriteriaModel();

  DiscoveryBloc({required DiscoveryRepository discoveryRepository})
      : _discoveryRepository = discoveryRepository,
        super(DiscoveryInitial()) {
    on<SearchPropertiesRequested>(_onSearchProperties);
    on<RadiusChanged>(_onRadiusChanged);
    on<FilterCriteriaUpdated>(_onFilterCriteriaUpdated);
    on<FiltersReset>(_onFiltersReset);
  }

  Future<void> _onSearchProperties(
    SearchPropertiesRequested event,
    Emitter<DiscoveryState> emit,
  ) async {
    _currentCriteria = event.criteria;
    emit(DiscoveryLoading());
    try {
      final result = await _discoveryRepository.searchProperties(_currentCriteria);
      emit(DiscoveryLoaded(
        properties: result['properties'],
        totalElements: result['totalElements'],
        currentCriteria: _currentCriteria,
      ));
    } catch (e) {
      emit(DiscoveryError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onRadiusChanged(
    RadiusChanged event,
    Emitter<DiscoveryState> emit,
  ) async {
    _currentCriteria = _currentCriteria.copyWith(radiusKm: event.radiusKm, page: 0);
    add(SearchPropertiesRequested(criteria: _currentCriteria));
  }

  Future<void> _onFilterCriteriaUpdated(
    FilterCriteriaUpdated event,
    Emitter<DiscoveryState> emit,
  ) async {
    _currentCriteria = event.criteria;
    add(SearchPropertiesRequested(criteria: _currentCriteria));
  }

  Future<void> _onFiltersReset(
    FiltersReset event,
    Emitter<DiscoveryState> emit,
  ) async {
    _currentCriteria = const SearchCriteriaModel();
    add(SearchPropertiesRequested(criteria: _currentCriteria));
  }
}
