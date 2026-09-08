import 'package:equatable/equatable.dart';
import '../models/bed_model.dart';
import '../models/property_detail_model.dart';
import '../models/room_model.dart';

abstract class PropertyDetailState extends Equatable {
  const PropertyDetailState();

  @override
  List<Object?> get props => [];
}

class PropertyDetailInitial extends PropertyDetailState {}

class PropertyDetailLoading extends PropertyDetailState {}

class PropertyDetailLoaded extends PropertyDetailState {
  final PropertyDetailModel property;
  final RoomModel? selectedRoom;
  final BedModel? selectedBed;

  const PropertyDetailLoaded({
    required this.property,
    this.selectedRoom,
    this.selectedBed,
  });

  PropertyDetailLoaded copyWith({
    PropertyDetailModel? property,
    RoomModel? selectedRoom,
    BedModel? selectedBed,
  }) {
    return PropertyDetailLoaded(
      property: property ?? this.property,
      selectedRoom: selectedRoom ?? this.selectedRoom,
      selectedBed: selectedBed ?? this.selectedBed,
    );
  }

  @override
  List<Object?> get props => [property, selectedRoom, selectedBed];
}

class PropertyDetailError extends PropertyDetailState {
  final String message;

  const PropertyDetailError(this.message);

  @override
  List<Object?> get props => [message];
}
