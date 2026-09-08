import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../models/property_summary_model.dart';

class PropertyCard extends StatelessWidget {
  final PropertySummaryModel property;
  final VoidCallback onTap;

  const PropertyCard({
    super.key,
    required this.property,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

    String genderTag = 'Unisex PG';
    Color genderBg = AppColors.primary.withValues(alpha: 0.1);
    Color genderTextColor = AppColors.primary;

    if (property.propertyType == 'PG_BOYS') {
      genderTag = 'Boys PG';
      genderBg = Colors.blue.withValues(alpha: 0.1);
      genderTextColor = Colors.blue[700]!;
    } else if (property.propertyType == 'PG_GIRLS') {
      genderTag = 'Girls PG';
      genderBg = Colors.pink.withValues(alpha: 0.1);
      genderTextColor = Colors.pink[700]!;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Property Image with Badges
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                  child: property.coverImageUrl != null && property.coverImageUrl!.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: property.coverImageUrl!,
                          height: 180,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Container(
                            height: 180,
                            color: Colors.grey[100],
                            child: const Center(child: Icon(Icons.image, color: Colors.grey)),
                          ),
                          errorWidget: (_, __, ___) => Container(
                            height: 180,
                            color: Colors.grey[200],
                            child: const Center(child: Icon(Icons.apartment_rounded, size: 48, color: Colors.grey)),
                          ),
                        )
                      : Container(
                          height: 180,
                          color: AppColors.primary.withValues(alpha: 0.08),
                          child: const Center(child: Icon(Icons.apartment_rounded, size: 48, color: AppColors.primary)),
                        ),
                ),
                // Gender Tag
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: genderBg,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: genderTextColor.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      genderTag,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: genderTextColor,
                      ),
                    ),
                  ),
                ),
                // Distance Badge
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.location_on, color: Colors.white, size: 12),
                        const SizedBox(width: 4),
                        Text(
                          '${property.distanceKm.toStringAsFixed(1)} km away',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // Details
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          property.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: property.totalVacantBeds > 0
                              ? AppColors.successBackground
                              : AppColors.errorBackground,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          property.totalVacantBeds > 0
                              ? '${property.totalVacantBeds} Beds Vacant'
                              : 'Full',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: property.totalVacantBeds > 0
                                ? AppColors.success
                                : AppColors.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${property.addressLine}, ${property.city}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  // Amenities row
                  if (property.amenities.isNotEmpty) ...[
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: property.amenities.take(3).map((amenity) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Text(
                            amenity,
                            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 12),
                  ],
                  const Divider(),
                  const SizedBox(height: 8),
                  // Price and CTA
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Starts from',
                            style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                          ),
                          Text(
                            '${currencyFormatter.format(property.minMonthlyRent)}/mo',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'View Beds',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
