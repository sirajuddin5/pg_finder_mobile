import 'package:equatable/equatable.dart';
import '../models/search_criteria_model.dart';

abstract class DiscoveryEvent extends Equatable {
  const DiscoveryEvent();

  @override
  List<Object?> get props => [];
}

class SearchPropertiesRequested extends DiscoveryEvent {
  final SearchCriteriaModel criteria;

  const SearchPropertiesRequested({required this.criteria});

  @override
  List<Object?> get props => [criteria];
}

class RadiusChanged extends DiscoveryEvent {
  final double radiusKm;

  const RadiusChanged(this.radiusKm);

  @override
  List<Object?> get props => [radiusKm];
}

class FilterCriteriaUpdated extends DiscoveryEvent {
  final SearchCriteriaModel criteria;

  const FilterCriteriaUpdated(this.criteria);

  @override
  List<Object?> get props => [criteria];
}

class FiltersReset extends DiscoveryEvent {}
