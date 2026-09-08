import 'package:equatable/equatable.dart';
import '../../discovery/models/property_summary_model.dart';
import '../../property/models/property_detail_model.dart';
import '../../tenant_portal/models/complaint_model.dart';
import '../models/admin_stats_model.dart';
import '../models/admin_user_model.dart';
import '../models/kyc_document_model.dart';

abstract class AdminState extends Equatable {
  const AdminState();

  @override
  List<Object?> get props => [];
}

class AdminInitial extends AdminState {}

class AdminLoading extends AdminState {}

class AdminDashboardLoaded extends AdminState {
  final AdminStatsModel stats;

  const AdminDashboardLoaded(this.stats);

  @override
  List<Object?> get props => [stats];
}

class PendingPropertiesLoaded extends AdminState {
  final List<PropertySummaryModel> properties;

  const PendingPropertiesLoaded(this.properties);

  @override
  List<Object?> get props => [properties];
}

class PropertyVerifiedSuccess extends AdminState {
  final PropertyDetailModel property;
  final String message;

  const PropertyVerifiedSuccess({
    required this.property,
    required this.message,
  });

  @override
  List<Object?> get props => [property, message];
}

class PendingKycLoaded extends AdminState {
  final List<KycDocumentModel> documents;

  const PendingKycLoaded(this.documents);

  @override
  List<Object?> get props => [documents];
}

class KycVerifiedSuccess extends AdminState {
  final KycDocumentModel document;
  final String message;

  const KycVerifiedSuccess({
    required this.document,
    required this.message,
  });

  @override
  List<Object?> get props => [document, message];
}

class MonthlyInvoicingSuccess extends AdminState {
  final DateTime billingMonth;
  final int invoicesGenerated;
  final String message;

  const MonthlyInvoicingSuccess({
    required this.billingMonth,
    required this.invoicesGenerated,
    required this.message,
  });

  @override
  List<Object?> get props => [billingMonth, invoicesGenerated, message];
}

class AllComplaintsLoaded extends AdminState {
  final List<ComplaintModel> complaints;

  const AllComplaintsLoaded(this.complaints);

  @override
  List<Object?> get props => [complaints];
}

class UsersLoaded extends AdminState {
  final List<AdminUserModel> users;

  const UsersLoaded(this.users);

  @override
  List<Object?> get props => [users];
}

class SystemHealthLoaded extends AdminState {
  final Map<String, dynamic> health;

  const SystemHealthLoaded(this.health);

  @override
  List<Object?> get props => [health];
}

class AdminError extends AdminState {
  final String message;

  const AdminError(this.message);

  @override
  List<Object?> get props => [message];
}
