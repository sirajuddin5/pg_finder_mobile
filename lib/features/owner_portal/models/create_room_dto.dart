class CreateRoomDto {
  final String roomNumber;
  final int floorNumber;
  final String sharingType;
  final double baseRentMonthly;
  final double securityDeposit;
  final bool hasAc;
  final bool hasAttachedBathroom;
  final bool hasBalcony;
  final bool autoGenerateBeds;

  const CreateRoomDto({
    required this.roomNumber,
    required this.floorNumber,
    required this.sharingType,
    required this.baseRentMonthly,
    required this.securityDeposit,
    this.hasAc = false,
    this.hasAttachedBathroom = true,
    this.hasBalcony = false,
    this.autoGenerateBeds = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'roomNumber': roomNumber,
      'floorNumber': floorNumber,
      'sharingType': sharingType,
      'baseRentMonthly': baseRentMonthly,
      'securityDeposit': securityDeposit,
      'hasAc': hasAc,
      'hasAttachedBathroom': hasAttachedBathroom,
      'hasBalcony': hasBalcony,
      'autoGenerateBeds': autoGenerateBeds,
    };
  }
}
