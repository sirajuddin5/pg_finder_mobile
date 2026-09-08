import 'package:equatable/equatable.dart';

class PropertySummaryModel extends Equatable {
  final int id;
  final String title;
  final String propertyType;
  final String addressLine;
  final String city;
  final double latitude;
  final double longitude;
  final double distanceKm;
  final double minMonthlyRent;
  final int totalVacantBeds;
  final bool foodAvailable;
  final String foodType;
  final String? coverImageUrl;
  final List<String> amenities;
  final List<String> availableSharingTypes;

  const PropertySummaryModel({
    required this.id,
    required this.title,
    required this.propertyType,
    required this.addressLine,
    required this.city,
    required this.latitude,
    required this.longitude,
    required this.distanceKm,
    required this.minMonthlyRent,
    required this.totalVacantBeds,
    required this.foodAvailable,
    required this.foodType,
    this.coverImageUrl,
    this.amenities = const [],
    this.availableSharingTypes = const [],
  });

  factory PropertySummaryModel.fromJson(Map<String, dynamic> json) {
    return PropertySummaryModel(
      id: json['id'] as int,
      title: json['title'] as String? ?? '',
      propertyType: json['propertyType'] as String? ?? '',
      addressLine: json['addressLine'] as String? ?? '',
      city: json['city'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      distanceKm: (json['distanceKm'] as num?)?.toDouble() ?? 0.0,
      minMonthlyRent: (json['minMonthlyRent'] as num?)?.toDouble() ?? 0.0,
      totalVacantBeds: json['totalVacantBeds'] as int? ?? 0,
      foodAvailable: json['foodAvailable'] as bool? ?? false,
      foodType: json['foodType'] as String? ?? 'NONE',
      coverImageUrl: json['coverImageUrl'] as String?,
      amenities: (json['amenities'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      availableSharingTypes: (json['availableSharingTypes'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        propertyType,
        addressLine,
        city,
        latitude,
        longitude,
        distanceKm,
        minMonthlyRent,
        totalVacantBeds,
        foodAvailable,
        foodType,
        coverImageUrl,
        amenities,
        availableSharingTypes,
      ];
}
