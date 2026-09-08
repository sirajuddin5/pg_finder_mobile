import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/custom_button.dart';
import '../models/search_criteria_model.dart';

class FilterBottomSheet extends StatefulWidget {
  final SearchCriteriaModel initialCriteria;
  final ValueChanged<SearchCriteriaModel> onApply;

  const FilterBottomSheet({
    super.key,
    required this.initialCriteria,
    required this.onApply,
  });

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late String? _propertyType;
  late String? _sharingType;
  late double _maxPrice;
  late bool? _hasAc;
  late bool? _foodAvailable;
  late bool? _hasAttachedBathroom;
  late String _sortBy;

  @override
  void initState() {
    super.initState();
    _propertyType = widget.initialCriteria.propertyType;
    _sharingType = widget.initialCriteria.sharingType;
    _maxPrice = widget.initialCriteria.maxPrice ?? 25000.0;
    _hasAc = widget.initialCriteria.hasAc;
    _foodAvailable = widget.initialCriteria.foodAvailable;
    _hasAttachedBathroom = widget.initialCriteria.hasAttachedBathroom;
    _sortBy = widget.initialCriteria.sortBy;
  }

  void _onApplyPressed() {
    final updated = widget.initialCriteria.copyWith(
      propertyType: _propertyType,
      sharingType: _sharingType,
      maxPrice: _maxPrice,
      hasAc: _hasAc,
      foodAvailable: _foodAvailable,
      hasAttachedBathroom: _hasAttachedBathroom,
      sortBy: _sortBy,
      page: 0,
    );
    widget.onApply(updated);
    Navigator.of(context).pop();
  }

  void _onResetPressed() {
    setState(() {
      _propertyType = null;
      _sharingType = null;
      _maxPrice = 25000.0;
      _hasAc = null;
      _foodAvailable = null;
      _hasAttachedBathroom = null;
      _sortBy = 'DISTANCE_ASC';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Filters & Sort',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                TextButton(
                  onPressed: _onResetPressed,
                  child: const Text('Reset All'),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 12),
            // Gender
            const Text(
              'Gender / PG Type',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                _buildFilterChip('All', _propertyType == null, () => setState(() => _propertyType = null)),
                _buildFilterChip('Boys', _propertyType == 'PG_BOYS', () => setState(() => _propertyType = 'PG_BOYS')),
                _buildFilterChip('Girls', _propertyType == 'PG_GIRLS', () => setState(() => _propertyType = 'PG_GIRLS')),
                _buildFilterChip('Co-Ed', _propertyType == 'CO_ED', () => setState(() => _propertyType = 'CO_ED')),
              ],
            ),
            const SizedBox(height: 20),
            // Sharing Type
            const Text(
              'Room Sharing',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                _buildFilterChip('Any', _sharingType == null, () => setState(() => _sharingType = null)),
                _buildFilterChip('Single', _sharingType == 'SINGLE', () => setState(() => _sharingType = 'SINGLE')),
                _buildFilterChip('Double', _sharingType == 'DOUBLE', () => setState(() => _sharingType = 'DOUBLE')),
                _buildFilterChip('Triple', _sharingType == 'TRIPLE', () => setState(() => _sharingType = 'TRIPLE')),
                _buildFilterChip('4+ Sharing', _sharingType == 'FOUR_PLUS', () => setState(() => _sharingType = 'FOUR_PLUS')),
              ],
            ),
            const SizedBox(height: 20),
            // Max Budget Slider
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Max Budget',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                ),
                Text(
                  '₹${_maxPrice.toInt()}/mo',
                  style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary),
                ),
              ],
            ),
            Slider(
              value: _maxPrice,
              min: 3000,
              max: 35000,
              divisions: 32,
              activeColor: AppColors.primary,
              onChanged: (v) => setState(() => _maxPrice = v),
            ),
            const SizedBox(height: 12),
            // Amenities Toggles
            const Text(
              'Amenities & Preferences',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
            ),
            const SizedBox(height: 8),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: const Text('Air Conditioning (AC) Only', style: TextStyle(fontSize: 14)),
              value: _hasAc ?? false,
              activeColor: AppColors.primary,
              onChanged: (v) => setState(() => _hasAc = v ? true : null),
            ),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: const Text('Food / Meals Included', style: TextStyle(fontSize: 14)),
              value: _foodAvailable ?? false,
              activeColor: AppColors.primary,
              onChanged: (v) => setState(() => _foodAvailable = v ? true : null),
            ),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: const Text('Attached Bathroom', style: TextStyle(fontSize: 14)),
              value: _hasAttachedBathroom ?? false,
              activeColor: AppColors.primary,
              onChanged: (v) => setState(() => _hasAttachedBathroom = v ? true : null),
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: 'Apply Filters',
              onPressed: _onApplyPressed,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap) {
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      selectedColor: AppColors.primary.withValues(alpha: 0.15),
      labelStyle: TextStyle(
        color: isSelected ? AppColors.primary : AppColors.textSecondary,
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
      ),
      side: BorderSide(
        color: isSelected ? AppColors.primary : AppColors.border,
      ),
    );
  }
}
