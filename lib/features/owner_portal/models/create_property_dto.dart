class CreatePropertyDto {
  final String title;
  final String description;
  final String propertyType;
  final String addressLine;
  final String city;
  final String state;
  final String pincode;
  final double latitude;
  final double longitude;
  final int noticePeriodDays;
  final String? gateClosingTime;
  final bool foodAvailable;
  final String foodType;
  final List<int> amenityIds;

  const CreatePropertyDto({
    required this.title,
    required this.description,
    required this.propertyType,
    required this.addressLine,
    required this.city,
    required this.state,
    required this.pincode,
    required this.latitude,
    required this.longitude,
    this.noticePeriodDays = 30,
    this.gateClosingTime,
    this.foodAvailable = true,
    this.foodType = 'BOTH',
    this.amenityIds = const [],
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'title': title,
      'description': description,
      'propertyType': propertyType,
      'addressLine': addressLine,
      'city': city,
      'state': state,
      'pincode': pincode,
      'latitude': latitude,
      'longitude': longitude,
      'noticePeriodDays': noticePeriodDays,
      'foodAvailable': foodAvailable,
      'foodType': foodType,
      'amenityIds': amenityIds,
    };

    if (gateClosingTime != null && gateClosingTime!.isNotEmpty) {
      map['gateClosingTime'] = gateClosingTime;
    }

    return map;
  }
}
