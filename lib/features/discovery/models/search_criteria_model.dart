import 'package:equatable/equatable.dart';

class SearchCriteriaModel extends Equatable {
  final double latitude;
  final double longitude;
  final double radiusKm;
  final String? propertyType;
  final String? sharingType;
  final double? minPrice;
  final double? maxPrice;
  final bool? hasAc;
  final bool? foodAvailable;
  final bool? hasAttachedBathroom;
  final String sortBy;
  final int page;
  final int size;

  const SearchCriteriaModel({
    this.latitude = 12.9716, // Bengaluru center default
    this.longitude = 77.5946,
    this.radiusKm = 5.0,
    this.propertyType,
    this.sharingType,
    this.minPrice,
    this.maxPrice,
    this.hasAc,
    this.foodAvailable,
    this.hasAttachedBathroom,
    this.sortBy = 'DISTANCE_ASC',
    this.page = 0,
    this.size = 20,
  });

  SearchCriteriaModel copyWith({
    double? latitude,
    double? longitude,
    double? radiusKm,
    String? propertyType,
    String? sharingType,
    double? minPrice,
    double? maxPrice,
    bool? hasAc,
    bool? foodAvailable,
    bool? hasAttachedBathroom,
    String? sortBy,
    int? page,
    int? size,
  }) {
    return SearchCriteriaModel(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      radiusKm: radiusKm ?? this.radiusKm,
      propertyType: propertyType ?? this.propertyType,
      sharingType: sharingType ?? this.sharingType,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      hasAc: hasAc ?? this.hasAc,
      foodAvailable: foodAvailable ?? this.foodAvailable,
      hasAttachedBathroom: hasAttachedBathroom ?? this.hasAttachedBathroom,
      sortBy: sortBy ?? this.sortBy,
      page: page ?? this.page,
      size: size ?? this.size,
    );
  }

  Map<String, dynamic> toQueryParameters() {
    final params = <String, dynamic>{
      'lat': latitude,
      'lng': longitude,
      'radiusKm': radiusKm,
      'sortBy': sortBy,
      'page': page,
      'size': size,
    };

    if (propertyType != null && propertyType!.isNotEmpty) params['propertyType'] = propertyType;
    if (sharingType != null && sharingType!.isNotEmpty) params['sharingType'] = sharingType;
    if (minPrice != null) params['minPrice'] = minPrice;
    if (maxPrice != null) params['maxPrice'] = maxPrice;
    if (hasAc != null) params['hasAc'] = hasAc;
    if (foodAvailable != null) params['foodAvailable'] = foodAvailable;
    if (hasAttachedBathroom != null) params['hasAttachedBathroom'] = hasAttachedBathroom;

    return params;
  }

  @override
  List<Object?> get props => [
        latitude,
        longitude,
        radiusKm,
        propertyType,
        sharingType,
        minPrice,
        maxPrice,
        hasAc,
        foodAvailable,
        hasAttachedBathroom,
        sortBy,
        page,
        size,
      ];
}
