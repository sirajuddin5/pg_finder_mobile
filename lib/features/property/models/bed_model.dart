import 'package:equatable/equatable.dart';

class BedModel extends Equatable {
  final int id;
  final String bedIdentifier;
  final bool isAvailable;
  final String status;

  const BedModel({
    required this.id,
    required this.bedIdentifier,
    required this.isAvailable,
    required this.status,
  });

  factory BedModel.fromJson(Map<String, dynamic> json) {
    return BedModel(
      id: json['id'] as int,
      bedIdentifier: json['bedIdentifier'] as String? ?? '',
      isAvailable: json['isAvailable'] as bool? ?? false,
      status: json['status'] as String? ?? 'VACANT',
    );
  }

  bool get isVacant => status == 'VACANT' && isAvailable;
  bool get isReserved => status == 'RESERVED';
  bool get isOccupied => status == 'OCCUPIED';

  @override
  List<Object?> get props => [id, bedIdentifier, isAvailable, status];
}
