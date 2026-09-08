import 'package:equatable/equatable.dart';
import '../models/property_summary_model.dart';
import '../models/search_criteria_model.dart';

abstract class DiscoveryState extends Equatable {
  const DiscoveryState();

  @override
  List<Object?> get props => [];
}

class DiscoveryInitial extends DiscoveryState {}

class DiscoveryLoading extends DiscoveryState {}

class DiscoveryLoaded extends DiscoveryState {
  final List<PropertySummaryModel> properties;
  final int totalElements;
  final SearchCriteriaModel currentCriteria;

  const DiscoveryLoaded({
    required this.properties,
    required this.totalElements,
    required this.currentCriteria,
  });

  @override
  List<Object?> get props => [properties, totalElements, currentCriteria];
}

class DiscoveryError extends DiscoveryState {
  final String message;

  const DiscoveryError(this.message);

  @override
  List<Object?> get props => [message];
}
