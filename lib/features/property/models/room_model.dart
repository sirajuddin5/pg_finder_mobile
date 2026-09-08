import 'package:equatable/equatable.dart';
import 'bed_model.dart';

class RoomModel extends Equatable {
  final int id;
  final String roomNumber;
  final int floorNumber;
  final String sharingType;
  final double baseRentMonthly;
  final double securityDeposit;
  final bool hasAc;
  final bool hasAttachedBathroom;
  final bool hasBalcony;
  final List<BedModel> beds;

  const RoomModel({
    required this.id,
    required this.roomNumber,
    required this.floorNumber,
    required this.sharingType,
    required this.baseRentMonthly,
    required this.securityDeposit,
    required this.hasAc,
    required this.hasAttachedBathroom,
    required this.hasBalcony,
    this.beds = const [],
  });

  factory RoomModel.fromJson(Map<String, dynamic> json) {
    return RoomModel(
      id: json['id'] as int,
      roomNumber: json['roomNumber'] as String? ?? '',
      floorNumber: json['floorNumber'] as int? ?? 1,
      sharingType: json['sharingType'] as String? ?? 'SINGLE',
      baseRentMonthly: (json['baseRentMonthly'] as num?)?.toDouble() ?? 0.0,
      securityDeposit: (json['securityDeposit'] as num?)?.toDouble() ?? 0.0,
      hasAc: json['hasAc'] as bool? ?? false,
      hasAttachedBathroom: json['hasAttachedBathroom'] as bool? ?? false,
      hasBalcony: json['hasBalcony'] as bool? ?? false,
      beds: (json['beds'] as List<dynamic>?)
              ?.map((e) => BedModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  int get vacantBedCount => beds.where((b) => b.isVacant).length;

  @override
  List<Object?> get props => [
        id,
        roomNumber,
        floorNumber,
        sharingType,
        baseRentMonthly,
        securityDeposit,
        hasAc,
        hasAttachedBathroom,
        hasBalcony,
        beds,
      ];
}
