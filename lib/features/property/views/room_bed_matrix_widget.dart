import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../models/bed_model.dart';
import '../models/room_model.dart';

class RoomBedMatrixWidget extends StatelessWidget {
  final List<RoomModel> rooms;
  final RoomModel? selectedRoom;
  final BedModel? selectedBed;
  final ValueChanged<RoomModel> onRoomSelected;
  final ValueChanged<BedModel> onBedSelected;

  const RoomBedMatrixWidget({
    super.key,
    required this.rooms,
    required this.selectedRoom,
    required this.selectedBed,
    required this.onRoomSelected,
    required this.onBedSelected,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

    if (rooms.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: const Text('No rooms currently available for this PG.'),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Horizontal Room Tabs
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: rooms.map((room) {
              final isSelected = selectedRoom?.id == room.id;
              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: GestureDetector(
                  onTap: () => onRoomSelected(room),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? AppColors.primary : AppColors.border,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Room ${room.roomNumber}',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: isSelected ? Colors.white : AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${room.sharingType} • ${currencyFormatter.format(room.baseRentMonthly)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: isSelected ? Colors.white.withValues(alpha: 0.85) : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 16),
        // Selected Room Bed Grid
        if (selectedRoom != null) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Select Bed (Room ${selectedRoom!.roomNumber})',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Row(
                      children: [
                        _buildLegend(AppColors.statusVacant, 'Vacant'),
                        const SizedBox(width: 8),
                        _buildLegend(AppColors.statusReserved, 'Reserved'),
                        const SizedBox(width: 8),
                        _buildLegend(AppColors.statusOccupied, 'Occupied'),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: selectedRoom!.beds.map((bed) {
                    final isBedSelected = selectedBed?.id == bed.id;
                    Color bedColor = AppColors.statusVacant;
                    if (bed.isReserved) bedColor = AppColors.statusReserved;
                    if (bed.isOccupied) bedColor = AppColors.statusOccupied;

                    return GestureDetector(
                      onTap: bed.isVacant ? () => onBedSelected(bed) : null,
                      child: Container(
                        width: 90,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: isBedSelected
                              ? AppColors.primary
                              : bedColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isBedSelected
                                ? AppColors.primary
                                : bedColor.withValues(alpha: 0.4),
                            width: isBedSelected ? 2 : 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.single_bed_rounded,
                              size: 28,
                              color: isBedSelected ? Colors.white : bedColor,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              bed.bedIdentifier,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: isBedSelected ? Colors.white : AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              bed.status,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: isBedSelected ? Colors.white.withValues(alpha: 0.8) : bedColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildLegend(Color color, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
      ],
    );
  }
}
