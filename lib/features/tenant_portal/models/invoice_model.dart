import 'package:equatable/equatable.dart';

class InvoiceModel extends Equatable {
  final int id;
  final String invoiceNumber;
  final int? bookingId;
  final String? bookingReference;
  final String? propertyTitle;
  final String? roomNumber;
  final String? bedIdentifier;
  final String billingMonth;
  final double rentAmount;
  final double utilityCharges;
  final double lateFee;
  final double totalAmount;
  final String dueDate;
  final String status;
  final String? paidAt;
  final String? transactionReference;

  const InvoiceModel({
    required this.id,
    required this.invoiceNumber,
    this.bookingId,
    this.bookingReference,
    this.propertyTitle,
    this.roomNumber,
    this.bedIdentifier,
    required this.billingMonth,
    required this.rentAmount,
    required this.utilityCharges,
    required this.lateFee,
    required this.totalAmount,
    required this.dueDate,
    required this.status,
    this.paidAt,
    this.transactionReference,
  });

  factory InvoiceModel.fromJson(Map<String, dynamic> json) {
    return InvoiceModel(
      id: json['id'] as int,
      invoiceNumber: json['invoiceNumber'] as String? ?? '',
      bookingId: json['bookingId'] as int?,
      bookingReference: json['bookingReference'] as String?,
      propertyTitle: json['propertyTitle'] as String?,
      roomNumber: json['roomNumber'] as String?,
      bedIdentifier: json['bedIdentifier'] as String?,
      billingMonth: json['billingMonth'] as String? ?? '',
      rentAmount: (json['rentAmount'] as num?)?.toDouble() ?? 0.0,
      utilityCharges: (json['utilityCharges'] as num?)?.toDouble() ?? 0.0,
      lateFee: (json['lateFee'] as num?)?.toDouble() ?? 0.0,
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      dueDate: json['dueDate'] as String? ?? '',
      status: json['status'] as String? ?? 'UNPAID',
      paidAt: json['paidAt'] as String?,
      transactionReference: json['transactionReference'] as String?,
    );
  }

  bool get isPaid => status == 'PAID';
  bool get isOverdue => status == 'OVERDUE';
  bool get isUnpaid => status == 'UNPAID';

  @override
  List<Object?> get props => [
        id,
        invoiceNumber,
        bookingId,
        propertyTitle,
        billingMonth,
        rentAmount,
        utilityCharges,
        lateFee,
        totalAmount,
        dueDate,
        status,
        paidAt,
      ];
}
