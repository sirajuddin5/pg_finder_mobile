import 'package:equatable/equatable.dart';
import 'room_model.dart';

class PropertyDetailModel extends Equatable {
  final int id;
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
  final bool isVerified;
  final List<String> images;
  final List<String> amenities;
  final List<RoomModel> rooms;
  final Map<String, dynamic>? owner;

  const PropertyDetailModel({
    required this.id,
    required this.title,
    required this.description,
    required this.propertyType,
    required this.addressLine,
    required this.city,
    required this.state,
    required this.pincode,
    required this.latitude,
    required this.longitude,
    required this.noticePeriodDays,
    this.gateClosingTime,
    required this.foodAvailable,
    required this.foodType,
    required this.isVerified,
    this.images = const [],
    this.amenities = const [],
    this.rooms = const [],
    this.owner,
  });

  factory PropertyDetailModel.fromJson(Map<String, dynamic> json) {
    return PropertyDetailModel(
      id: json['id'] as int,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      propertyType: json['propertyType'] as String? ?? '',
      addressLine: json['addressLine'] as String? ?? '',
      city: json['city'] as String? ?? '',
      state: json['state'] as String? ?? '',
      pincode: json['pincode'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      noticePeriodDays: json['noticePeriodDays'] as int? ?? 30,
      gateClosingTime: json['gateClosingTime'] as String?,
      foodAvailable: json['foodAvailable'] as bool? ?? false,
      foodType: json['foodType'] as String? ?? 'NONE',
      isVerified: json['isVerified'] as bool? ?? false,
      images: (json['images'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      amenities: (json['amenities'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      rooms: (json['rooms'] as List<dynamic>?)
              ?.map((e) => RoomModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      owner: json['owner'] as Map<String, dynamic>?,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        propertyType,
        addressLine,
        city,
        state,
        pincode,
        latitude,
        longitude,
        noticePeriodDays,
        gateClosingTime,
        foodAvailable,
        foodType,
        isVerified,
        images,
        amenities,
        rooms,
        owner,
      ];
}
