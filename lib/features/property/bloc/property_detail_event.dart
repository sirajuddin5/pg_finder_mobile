import 'package:equatable/equatable.dart';
import '../models/bed_model.dart';
import '../models/room_model.dart';

abstract class PropertyDetailEvent extends Equatable {
  const PropertyDetailEvent();

  @override
  List<Object?> get props => [];
}

class LoadPropertyDetailRequested extends PropertyDetailEvent {
  final int propertyId;

  const LoadPropertyDetailRequested(this.propertyId);

  @override
  List<Object?> get props => [propertyId];
}

class RoomSelected extends PropertyDetailEvent {
  final RoomModel room;

  const RoomSelected(this.room);

  @override
  List<Object?> get props => [room];
}

class BedSelected extends PropertyDetailEvent {
  final BedModel bed;

  const BedSelected(this.bed);

  @override
  List<Object?> get props => [bed];
}
