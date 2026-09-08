import 'package:flutter_bloc/flutter_bloc.dart';
import '../repositories/owner_repository.dart';
import 'owner_event.dart';
import 'owner_state.dart';

class OwnerBloc extends Bloc<OwnerEvent, OwnerState> {
  final OwnerRepository _ownerRepository;

  OwnerBloc({required OwnerRepository ownerRepository})
      : _ownerRepository = ownerRepository,
        super(OwnerInitial()) {
    on<LoadOwnerDashboardRequested>(_onLoadDashboard);
    on<CreatePropertySubmitted>(_onCreateProperty);
    on<CreateRoomSubmitted>(_onCreateRoom);
    on<UpdateComplaintStatusRequested>(_onUpdateComplaintStatus);
  }

  Future<void> _onLoadDashboard(
    LoadOwnerDashboardRequested event,
    Emitter<OwnerState> emit,
  ) async {
    emit(OwnerLoading());
    try {
      final properties = await _ownerRepository.getMyProperties();
      final complaints = await _ownerRepository.getOwnerComplaints();
      emit(OwnerDashboardLoaded(properties: properties, complaints: complaints));
    } catch (e) {
      emit(OwnerError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onCreateProperty(
    CreatePropertySubmitted event,
    Emitter<OwnerState> emit,
  ) async {
    emit(OwnerLoading());
    try {
      final created = await _ownerRepository.createProperty(event.dto);
      emit(PropertyCreatedSuccess(created));
      add(LoadOwnerDashboardRequested());
    } catch (e) {
      emit(OwnerError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onCreateRoom(
    CreateRoomSubmitted event,
    Emitter<OwnerState> emit,
  ) async {
    emit(OwnerLoading());
    try {
      final created = await _ownerRepository.createRoom(event.propertyId, event.dto);
      emit(RoomCreatedSuccess(created));
      add(LoadOwnerDashboardRequested());
    } catch (e) {
      emit(OwnerError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onUpdateComplaintStatus(
    UpdateComplaintStatusRequested event,
    Emitter<OwnerState> emit,
  ) async {
    try {
      await _ownerRepository.updateComplaintStatus(event.complaintId, event.status);
      add(LoadOwnerDashboardRequested());
    } catch (e) {
      emit(OwnerError(e.toString().replaceAll('Exception: ', '')));
    }
  }
}
