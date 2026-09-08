import 'package:equatable/equatable.dart';
import '../../booking/models/booking_model.dart';
import '../models/complaint_model.dart';
import '../models/invoice_model.dart';

abstract class TenantPortalState extends Equatable {
  const TenantPortalState();

  @override
  List<Object?> get props => [];
}

class TenantPortalInitial extends TenantPortalState {}

class TenantPortalLoading extends TenantPortalState {}

class TenantDashboardLoaded extends TenantPortalState {
  final List<BookingModel> stays;
  final List<InvoiceModel> invoices;
  final List<ComplaintModel> complaints;

  const TenantDashboardLoaded({
    required this.stays,
    required this.invoices,
    required this.complaints,
  });

  BookingModel? get activeStay =>
      stays.isNotEmpty ? stays.firstWhere((s) => s.isConfirmed, orElse: () => stays.first) : null;

  @override
  List<Object?> get props => [stays, invoices, complaints];
}

class InvoicePaymentSuccess extends TenantPortalState {
  final InvoiceModel invoice;

  const InvoicePaymentSuccess(this.invoice);

  @override
  List<Object?> get props => [invoice];
}

class ComplaintSubmissionSuccess extends TenantPortalState {
  final ComplaintModel complaint;

  const ComplaintSubmissionSuccess(this.complaint);

  @override
  List<Object?> get props => [complaint];
}

class TenantPortalError extends TenantPortalState {
  final String message;

  const TenantPortalError(this.message);

  @override
  List<Object?> get props => [message];
}
