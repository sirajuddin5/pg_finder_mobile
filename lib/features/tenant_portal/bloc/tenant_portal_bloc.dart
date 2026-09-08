import 'package:flutter_bloc/flutter_bloc.dart';
import '../repositories/tenant_portal_repository.dart';
import 'tenant_portal_event.dart';
import 'tenant_portal_state.dart';

class TenantPortalBloc extends Bloc<TenantPortalEvent, TenantPortalState> {
  final TenantPortalRepository _tenantPortalRepository;

  TenantPortalBloc({required TenantPortalRepository tenantPortalRepository})
      : _tenantPortalRepository = tenantPortalRepository,
        super(TenantPortalInitial()) {
    on<LoadTenantDashboardRequested>(_onLoadDashboard);
    on<PayInvoiceRequested>(_onPayInvoice);
    on<SubmitComplaintRequested>(_onSubmitComplaint);
  }

  Future<void> _onLoadDashboard(
    LoadTenantDashboardRequested event,
    Emitter<TenantPortalState> emit,
  ) async {
    emit(TenantPortalLoading());
    try {
      final stays = await _tenantPortalRepository.getMyStays();
      final invoices = await _tenantPortalRepository.getMyInvoices();
      final complaints = await _tenantPortalRepository.getMyComplaints();

      emit(TenantDashboardLoaded(
        stays: stays,
        invoices: invoices,
        complaints: complaints,
      ));
    } catch (e) {
      emit(TenantPortalError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onPayInvoice(
    PayInvoiceRequested event,
    Emitter<TenantPortalState> emit,
  ) async {
    emit(TenantPortalLoading());
    try {
      final orderId = 'order_inv_${event.invoiceId}';
      final paymentId = 'pay_inv_${DateTime.now().millisecondsSinceEpoch}';
      final signature = 'sig_inv_${orderId}_$paymentId';

      final paidInvoice = await _tenantPortalRepository.payInvoice(
        invoiceId: event.invoiceId,
        orderId: orderId,
        paymentId: paymentId,
        signature: signature,
      );

      emit(InvoicePaymentSuccess(paidInvoice));
      add(LoadTenantDashboardRequested());
    } catch (e) {
      emit(TenantPortalError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onSubmitComplaint(
    SubmitComplaintRequested event,
    Emitter<TenantPortalState> emit,
  ) async {
    emit(TenantPortalLoading());
    try {
      final created = await _tenantPortalRepository.createComplaint(
        propertyId: event.propertyId,
        category: event.category,
        title: event.title,
        description: event.description,
        attachmentUrl: event.attachmentUrl,
      );

      emit(ComplaintSubmissionSuccess(created));
      add(LoadTenantDashboardRequested());
    } catch (e) {
      emit(TenantPortalError(e.toString().replaceAll('Exception: ', '')));
    }
  }
}
