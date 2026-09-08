import 'package:equatable/equatable.dart';

abstract class AdminEvent extends Equatable {
  const AdminEvent();

  @override
  List<Object?> get props => [];
}

class FetchAdminDashboardRequested extends AdminEvent {}

class FetchPendingPropertiesRequested extends AdminEvent {}

class VerifyPropertySubmitted extends AdminEvent {
  final int propertyId;
  final bool verified;
  final String? remarks;

  const VerifyPropertySubmitted({
    required this.propertyId,
    required this.verified,
    this.remarks,
  });

  @override
  List<Object?> get props => [propertyId, verified, remarks];
}

class FetchPendingKycRequested extends AdminEvent {}

class VerifyKycSubmitted extends AdminEvent {
  final int documentId;
  final String status;
  final String? rejectionReason;

  const VerifyKycSubmitted({
    required this.documentId,
    required this.status,
    this.rejectionReason,
  });

  @override
  List<Object?> get props => [documentId, status, rejectionReason];
}

class TriggerMonthlyInvoicingSubmitted extends AdminEvent {
  final DateTime billingMonth;

  const TriggerMonthlyInvoicingSubmitted(this.billingMonth);

  @override
  List<Object?> get props => [billingMonth];
}

class FetchAllComplaintsRequested extends AdminEvent {}

class FetchUsersRequested extends AdminEvent {}

class FetchSystemHealthRequested extends AdminEvent {}
