import 'package:flutter_bloc/flutter_bloc.dart';
import '../../discovery/models/property_summary_model.dart';
import '../../tenant_portal/models/complaint_model.dart';
import '../repositories/owner_repository.dart';
import 'owner_event.dart';
import 'owner_state.dart';

class OwnerBloc extends Bloc<OwnerEvent, OwnerState> {
  final OwnerRepository _ownerRepository;

  OwnerBloc({required OwnerRepository ownerRepository})
      : _ownerRepository = ownerRepository,
        super(OwnerInitial()) {
    on<LoadOwnerDashboardRequested>(_onLoadDashboard);
    on<LoadOwnerPropertiesRequested>(_onLoadProperties);
    on<LoadOwnerComplaintsRequested>(_onLoadComplaints);
    on<CreatePropertySubmitted>(_onCreateProperty);
    on<CreateRoomSubmitted>(_onCreateRoom);
    on<UpdateBedStatusRequested>(_onUpdateBedStatus);
    on<LoadPropertyBedsRequested>(_onLoadPropertyBeds);
    on<LoadPropertyInvoicesRequested>(_onLoadPropertyInvoices);
    on<UpdateComplaintStatusRequested>(_onUpdateComplaintStatus);
  }

  Future<void> _onLoadDashboard(
    LoadOwnerDashboardRequested event,
    Emitter<OwnerState> emit,
  ) async {
    add(LoadOwnerPropertiesRequested());
  }

  Future<void> _onLoadProperties(
    LoadOwnerPropertiesRequested event,
    Emitter<OwnerState> emit,
  ) async {
    final currentComplaints = state is OwnerDashboardLoaded
        ? (state as OwnerDashboardLoaded).complaints
        : <ComplaintModel>[];

    if (state is! OwnerDashboardLoaded) {
      emit(OwnerLoading());
    }

    try {
      final properties = await _ownerRepository.getMyProperties();
      emit(OwnerDashboardLoaded(properties: properties, complaints: currentComplaints));
    } catch (e) {
      emit(OwnerError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onLoadComplaints(
    LoadOwnerComplaintsRequested event,
    Emitter<OwnerState> emit,
  ) async {
    final currentProperties = state is OwnerDashboardLoaded
        ? (state as OwnerDashboardLoaded).properties
        : <PropertySummaryModel>[];

    try {
      final complaints = await _ownerRepository.getOwnerComplaints();
      emit(OwnerDashboardLoaded(properties: currentProperties, complaints: complaints));
    } catch (_) {
      emit(OwnerDashboardLoaded(properties: currentProperties, complaints: const []));
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

  Future<void> _onUpdateBedStatus(
    UpdateBedStatusRequested event,
    Emitter<OwnerState> emit,
  ) async {
    try {
      final updatedBed = await _ownerRepository.updateBedStatus(event.bedId, event.status);
      emit(BedStatusUpdatedSuccess(
        bed: updatedBed,
        message: 'Bed ${updatedBed.bedIdentifier} marked as ${updatedBed.status}',
      ));
      if (event.propertyId != null) {
        add(LoadPropertyBedsRequested(propertyId: event.propertyId!));
      } else {
        add(LoadOwnerDashboardRequested());
      }
    } catch (e) {
      emit(OwnerError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onLoadPropertyBeds(
    LoadPropertyBedsRequested event,
    Emitter<OwnerState> emit,
  ) async {
    emit(OwnerLoading());
    try {
      final property = await _ownerRepository.getPropertyDetails(event.propertyId);
      emit(PropertyBedsLoaded(property));
    } catch (e) {
      emit(OwnerError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onLoadPropertyInvoices(
    LoadPropertyInvoicesRequested event,
    Emitter<OwnerState> emit,
  ) async {
    emit(OwnerLoading());
    try {
      final invoices = await _ownerRepository.getPropertyInvoices(event.propertyId);
      emit(PropertyInvoicesLoaded(invoices));
    } catch (e) {
      emit(OwnerError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onUpdateComplaintStatus(
    UpdateComplaintStatusRequested event,
    Emitter<OwnerState> emit,
  ) async {
    try {
      await _ownerRepository.updateComplaintStatus(
        event.complaintId,
        event.status,
        resolutionNotes: event.resolutionNotes,
      );
      add(LoadOwnerDashboardRequested());
    } catch (e) {
      emit(OwnerError(e.toString().replaceAll('Exception: ', '')));
    }
  }
}
