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

class UpdateBedStatusRequested extends OwnerEvent {
  final int bedId;
  final String status;
  final int? propertyId;

  const UpdateBedStatusRequested({
    required this.bedId,
    required this.status,
    this.propertyId,
  });

  @override
  List<Object?> get props => [bedId, status, propertyId];
}

class LoadPropertyBedsRequested extends OwnerEvent {
  final int propertyId;

  const LoadPropertyBedsRequested({required this.propertyId});

  @override
  List<Object?> get props => [propertyId];
}

class LoadPropertyInvoicesRequested extends OwnerEvent {
  final int propertyId;

  const LoadPropertyInvoicesRequested({required this.propertyId});

  @override
  List<Object?> get props => [propertyId];
}

class UpdateComplaintStatusRequested extends OwnerEvent {
  final int complaintId;
  final String status;
  final String? resolutionNotes;

  const UpdateComplaintStatusRequested({
    required this.complaintId,
    required this.status,
    this.resolutionNotes,
  });

  @override
  List<Object?> get props => [complaintId, status, resolutionNotes];
}
