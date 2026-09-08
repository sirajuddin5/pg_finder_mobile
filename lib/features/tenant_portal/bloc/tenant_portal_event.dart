import 'package:equatable/equatable.dart';

abstract class TenantPortalEvent extends Equatable {
  const TenantPortalEvent();

  @override
  List<Object?> get props => [];
}

class LoadTenantDashboardRequested extends TenantPortalEvent {}

class PayInvoiceRequested extends TenantPortalEvent {
  final int invoiceId;

  const PayInvoiceRequested(this.invoiceId);

  @override
  List<Object?> get props => [invoiceId];
}

class SubmitComplaintRequested extends TenantPortalEvent {
  final int propertyId;
  final String category;
  final String title;
  final String description;
  final String? attachmentUrl;

  const SubmitComplaintRequested({
    required this.propertyId,
    required this.category,
    required this.title,
    required this.description,
    this.attachmentUrl,
  });

  @override
  List<Object?> get props => [propertyId, category, title, description, attachmentUrl];
}
