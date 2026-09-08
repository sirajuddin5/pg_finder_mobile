import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/property_detail_model.dart';
import '../repositories/property_repository.dart';
import 'property_detail_event.dart';
import 'property_detail_state.dart';

class PropertyDetailBloc extends Bloc<PropertyDetailEvent, PropertyDetailState> {
  final PropertyRepository _propertyRepository;

  PropertyDetailBloc({required PropertyRepository propertyRepository})
      : _propertyRepository = propertyRepository,
        super(PropertyDetailInitial()) {
    on<LoadPropertyDetailRequested>(_onLoadPropertyDetail);
    on<RoomSelected>(_onRoomSelected);
    on<BedSelected>(_onBedSelected);
  }

  Future<void> _onLoadPropertyDetail(
    LoadPropertyDetailRequested event,
    Emitter<PropertyDetailState> emit,
  ) async {
    emit(PropertyDetailLoading());
    try {
      final property = await _propertyRepository.getPropertyDetails(event.propertyId);
      final rooms = await _propertyRepository.getPropertyRooms(event.propertyId);

      final fullProperty = PropertyDetailModel(
        id: property.id,
        title: property.title,
        description: property.description,
        propertyType: property.propertyType,
        addressLine: property.addressLine,
        city: property.city,
        state: property.state,
        pincode: property.pincode,
        latitude: property.latitude,
        longitude: property.longitude,
        noticePeriodDays: property.noticePeriodDays,
        gateClosingTime: property.gateClosingTime,
        foodAvailable: property.foodAvailable,
        foodType: property.foodType,
        isVerified: property.isVerified,
        images: property.images,
        amenities: property.amenities,
        rooms: rooms.isNotEmpty ? rooms : property.rooms,
        owner: property.owner,
      );

      final initialRoom = fullProperty.rooms.isNotEmpty ? fullProperty.rooms.first : null;
      final initialBed = initialRoom != null && initialRoom.beds.isNotEmpty
          ? initialRoom.beds.firstWhere((b) => b.isVacant, orElse: () => initialRoom.beds.first)
          : null;

      emit(PropertyDetailLoaded(
        property: fullProperty,
        selectedRoom: initialRoom,
        selectedBed: initialBed,
      ));
    } catch (e) {
      emit(PropertyDetailError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  void _onRoomSelected(
    RoomSelected event,
    Emitter<PropertyDetailState> emit,
  ) {
    if (state is PropertyDetailLoaded) {
      final current = state as PropertyDetailLoaded;
      final defaultBed = event.room.beds.isNotEmpty
          ? event.room.beds.firstWhere((b) => b.isVacant, orElse: () => event.room.beds.first)
          : null;

      emit(current.copyWith(
        selectedRoom: event.room,
        selectedBed: defaultBed,
      ));
    }
  }

  void _onBedSelected(
    BedSelected event,
    Emitter<PropertyDetailState> emit,
  ) {
    if (state is PropertyDetailLoaded) {
      final current = state as PropertyDetailLoaded;
      emit(current.copyWith(selectedBed: event.bed));
    }
  }
}
