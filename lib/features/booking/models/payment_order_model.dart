import 'package:equatable/equatable.dart';

class PaymentOrderModel extends Equatable {
  final String orderId;
  final double amount;
  final String currency;
  final String keyId;

  const PaymentOrderModel({
    required this.orderId,
    required this.amount,
    required this.currency,
    required this.keyId,
  });

  factory PaymentOrderModel.fromJson(Map<String, dynamic> json) {
    return PaymentOrderModel(
      orderId: json['orderId'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] as String? ?? 'INR',
      keyId: json['keyId'] as String? ?? '',
    );
  }

  @override
  List<Object?> get props => [orderId, amount, currency, keyId];
}
