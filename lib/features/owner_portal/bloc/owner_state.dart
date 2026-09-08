import 'package:equatable/equatable.dart';
import '../../discovery/models/property_summary_model.dart';
import '../../property/models/property_detail_model.dart';
import '../../property/models/room_model.dart';
import '../../tenant_portal/models/complaint_model.dart';

abstract class OwnerState extends Equatable {
  const OwnerState();

  @override
  List<Object?> get props => [];
}

class OwnerInitial extends OwnerState {}

class OwnerLoading extends OwnerState {}

class OwnerDashboardLoaded extends OwnerState {
  final List<PropertySummaryModel> properties;
  final List<ComplaintModel> complaints;

  const OwnerDashboardLoaded({
    required this.properties,
    required this.complaints,
  });

  int get totalProperties => properties.length;
  int get totalVacantBeds => properties.fold(0, (sum, p) => sum + p.totalVacantBeds);

  @override
  List<Object?> get props => [properties, complaints];
}

class PropertyCreatedSuccess extends OwnerState {
  final PropertyDetailModel property;

  const PropertyCreatedSuccess(this.property);

  @override
  List<Object?> get props => [property];
}

class RoomCreatedSuccess extends OwnerState {
  final RoomModel room;

  const RoomCreatedSuccess(this.room);

  @override
  List<Object?> get props => [room];
}

class OwnerError extends OwnerState {
  final String message;

  const OwnerError(this.message);

  @override
  List<Object?> get props => [message];
}
