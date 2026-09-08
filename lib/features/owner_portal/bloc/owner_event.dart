import 'package:equatable/equatable.dart';
import '../models/create_property_dto.dart';
import '../models/create_room_dto.dart';

abstract class OwnerEvent extends Equatable {
  const OwnerEvent();

  @override
  List<Object?> get props => [];
}

class LoadOwnerDashboardRequested extends OwnerEvent {}

class LoadOwnerPropertiesRequested extends OwnerEvent {}

class LoadOwnerComplaintsRequested extends OwnerEvent {}

class CreatePropertySubmitted extends OwnerEvent {
  final CreatePropertyDto dto;

  const CreatePropertySubmitted(this.dto);

  @override
  List<Object?> get props => [dto];
}

class CreateRoomSubmitted extends OwnerEvent {
  final int propertyId;
  final CreateRoomDto dto;

  const CreateRoomSubmitted({required this.propertyId, required this.dto});

  @override
  List<Object?> get props => [propertyId, dto];
}

class UpdateComplaintStatusRequested extends OwnerEvent {
  final int complaintId;
  final String status;

  const UpdateComplaintStatusRequested({required this.complaintId, required this.status});

  @override
  List<Object?> get props => [complaintId, status];
}
