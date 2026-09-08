import 'package:flutter_bloc/flutter_bloc.dart';
import '../repositories/admin_repository.dart';
import 'admin_event.dart';
import 'admin_state.dart';

class AdminBloc extends Bloc<AdminEvent, AdminState> {
  final AdminRepository _adminRepository;

  AdminBloc({required AdminRepository adminRepository})
      : _adminRepository = adminRepository,
        super(AdminInitial()) {
    on<FetchAdminDashboardRequested>(_onFetchAdminDashboard);
    on<FetchPendingPropertiesRequested>(_onFetchPendingProperties);
    on<VerifyPropertySubmitted>(_onVerifyProperty);
    on<FetchPendingKycRequested>(_onFetchPendingKyc);
    on<VerifyKycSubmitted>(_onVerifyKyc);
    on<TriggerMonthlyInvoicingSubmitted>(_onTriggerMonthlyInvoicing);
    on<FetchAllComplaintsRequested>(_onFetchAllComplaints);
    on<FetchUsersRequested>(_onFetchUsers);
    on<FetchSystemHealthRequested>(_onFetchSystemHealth);
  }

  Future<void> _onFetchAdminDashboard(
    FetchAdminDashboardRequested event,
    Emitter<AdminState> emit,
  ) async {
    emit(AdminLoading());
    try {
      final stats = await _adminRepository.getAdminStats();
      emit(AdminDashboardLoaded(stats));
    } catch (e) {
      emit(AdminError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onFetchPendingProperties(
    FetchPendingPropertiesRequested event,
    Emitter<AdminState> emit,
  ) async {
    emit(AdminLoading());
    try {
      final properties = await _adminRepository.getPendingProperties();
      emit(PendingPropertiesLoaded(properties));
    } catch (e) {
      emit(AdminError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onVerifyProperty(
    VerifyPropertySubmitted event,
    Emitter<AdminState> emit,
  ) async {
    emit(AdminLoading());
    try {
      final verifiedProp = await _adminRepository.verifyProperty(
        event.propertyId,
        event.verified,
        event.remarks,
      );
      final msg = event.verified
          ? 'Property "${verifiedProp.title}" approved successfully!'
          : 'Property listing rejected.';
      emit(PropertyVerifiedSuccess(property: verifiedProp, message: msg));

      // Refresh list
      final properties = await _adminRepository.getPendingProperties();
      emit(PendingPropertiesLoaded(properties));
    } catch (e) {
      emit(AdminError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onFetchPendingKyc(
    FetchPendingKycRequested event,
    Emitter<AdminState> emit,
  ) async {
    emit(AdminLoading());
    try {
      final documents = await _adminRepository.getPendingKycDocuments();
      emit(PendingKycLoaded(documents));
    } catch (e) {
      emit(AdminError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onVerifyKyc(
    VerifyKycSubmitted event,
    Emitter<AdminState> emit,
  ) async {
    emit(AdminLoading());
    try {
      final verifiedDoc = await _adminRepository.verifyKycDocument(
        event.documentId,
        event.status,
        event.rejectionReason,
      );
      final msg = event.status == 'VERIFIED'
          ? 'KYC document for ${verifiedDoc.userName} approved!'
          : 'KYC document rejected.';
      emit(KycVerifiedSuccess(document: verifiedDoc, message: msg));

      // Refresh list
      final documents = await _adminRepository.getPendingKycDocuments();
      emit(PendingKycLoaded(documents));
    } catch (e) {
      emit(AdminError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onTriggerMonthlyInvoicing(
    TriggerMonthlyInvoicingSubmitted event,
    Emitter<AdminState> emit,
  ) async {
    emit(AdminLoading());
    try {
      final result = await _adminRepository.generateMonthlyInvoices(event.billingMonth);
      final count = (result['invoicesGenerated'] as num?)?.toInt() ?? 0;
      emit(MonthlyInvoicingSuccess(
        billingMonth: event.billingMonth,
        invoicesGenerated: count,
        message: 'Generated $count rent invoices successfully.',
      ));
    } catch (e) {
      emit(AdminError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onFetchAllComplaints(
    FetchAllComplaintsRequested event,
    Emitter<AdminState> emit,
  ) async {
    emit(AdminLoading());
    try {
      final complaints = await _adminRepository.getAllComplaints();
      emit(AllComplaintsLoaded(complaints));
    } catch (e) {
      emit(AdminError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onFetchUsers(
    FetchUsersRequested event,
    Emitter<AdminState> emit,
  ) async {
    emit(AdminLoading());
    try {
      final users = await _adminRepository.getUsers();
      emit(UsersLoaded(users));
    } catch (e) {
      emit(AdminError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onFetchSystemHealth(
    FetchSystemHealthRequested event,
    Emitter<AdminState> emit,
  ) async {
    emit(AdminLoading());
    try {
      final health = await _adminRepository.getSystemHealth();
      emit(SystemHealthLoaded(health));
    } catch (e) {
      emit(AdminError(e.toString().replaceAll('Exception: ', '')));
    }
  }
}
