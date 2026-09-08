import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../bloc/owner_bloc.dart';
import '../bloc/owner_event.dart';
import '../bloc/owner_state.dart';
import '../models/create_property_dto.dart';

class AddPropertyScreen extends StatefulWidget {
  const AddPropertyScreen({super.key});

  @override
  State<AddPropertyScreen> createState() => _AddPropertyScreenState();
}

class _AddPropertyScreenState extends State<AddPropertyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _pincodeController = TextEditingController();
  final _latController = TextEditingController(text: '28.5921');
  final _lngController = TextEditingController(text: '77.0460');
  final _gateClosingController = TextEditingController(text: '22:30:00');

  String _propertyType = 'PG_BOYS';
  String _foodType = 'BOTH';
  bool _foodAvailable = true;
  final int _noticePeriodDays = 30;
  final Set<int> _selectedAmenityIds = {1, 2, 3, 5};

  final Map<int, String> _amenityOptions = {
    1: 'High-Speed Wi-Fi',
    2: 'Air Conditioning (AC)',
    3: 'Hot Water Geyser',
    4: 'Washing Machine',
    5: 'RO Purified Drinking Water',
    6: '24/7 CCTV Security',
    7: 'Power Backup (Inverter/DG)',
    8: 'Daily Housekeeping',
  };

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();
    _latController.dispose();
    _lngController.dispose();
    _gateClosingController.dispose();
    super.dispose();
  }

  void _onSubmitPressed() {
    if (_formKey.currentState?.validate() ?? false) {
      final dto = CreatePropertyDto(
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        propertyType: _propertyType,
        addressLine: _addressController.text.trim(),
        city: _cityController.text.trim(),
        state: _stateController.text.trim(),
        pincode: _pincodeController.text.trim(),
        latitude: double.tryParse(_latController.text) ?? 28.5921,
        longitude: double.tryParse(_lngController.text) ?? 77.0460,
        noticePeriodDays: _noticePeriodDays,
        gateClosingTime: _gateClosingController.text.trim().isNotEmpty
            ? _gateClosingController.text.trim()
            : null,
        foodAvailable: _foodAvailable,
        foodType: _foodType,
        amenityIds: _selectedAmenityIds.toList(),
      );

      context.read<OwnerBloc>().add(CreatePropertySubmitted(dto));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('List New PG Property'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocConsumer<OwnerBloc, OwnerState>(
        listener: (context, state) {
          if (state is PropertyCreatedSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Property "${state.property.title}" listed successfully!'),
                backgroundColor: AppColors.success,
                behavior: SnackBarBehavior.floating,
              ),
            );
            context.pop();
          } else if (state is OwnerError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is OwnerLoading;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section 1: Property Overview
                  _buildSectionCard(
                    title: '1. Basic Information',
                    icon: Icons.apartment_rounded,
                    children: [
                      CustomTextField(
                        controller: _titleController,
                        label: 'Property Title',
                        hint: 'e.g. Comfort Stay Boys PG',
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter PG title' : null,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _descController,
                        label: 'Description',
                        hint: 'Highlight key features, rules, food timings, cleanliness...',
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),
                      const Text('PG Gender Category', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _propertyType,
                        items: const [
                          DropdownMenuItem(value: 'PG_BOYS', child: Text('Boys PG')),
                          DropdownMenuItem(value: 'PG_GIRLS', child: Text('Girls PG')),
                          DropdownMenuItem(value: 'CO_ED', child: Text('Co-Ed / Unisex PG')),
                          DropdownMenuItem(value: 'FLAT_SHARE', child: Text('Flat Share / Managed Apartment')),
                        ],
                        onChanged: (v) {
                          if (v != null) setState(() => _propertyType = v);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Section 2: Address & Coordinates
                  _buildSectionCard(
                    title: '2. Location & Address',
                    icon: Icons.location_on_outlined,
                    children: [
                      CustomTextField(
                        controller: _addressController,
                        label: 'Street / Plot / Area',
                        hint: 'Plot No. 24, Sector 15, Near Metro',
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Address is required' : null,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: CustomTextField(
                              controller: _cityController,
                              label: 'City',
                              hint: 'New Delhi',
                              validator: (v) => (v == null || v.trim().isEmpty) ? 'City required' : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: CustomTextField(
                              controller: _stateController,
                              label: 'State',
                              hint: 'Delhi',
                              validator: (v) => (v == null || v.trim().isEmpty) ? 'State required' : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: CustomTextField(
                              controller: _pincodeController,
                              label: 'Pincode',
                              hint: '110075',
                              keyboardType: TextInputType.number,
                              validator: (v) => (v == null || v.trim().isEmpty) ? 'Pincode required' : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: CustomTextField(
                              controller: _latController,
                              label: 'Latitude',
                              hint: '28.5921',
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: CustomTextField(
                              controller: _lngController,
                              label: 'Longitude',
                              hint: '77.0460',
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Section 3: Rules & Food
                  _buildSectionCard(
                    title: '3. Rules, Timings & Food',
                    icon: Icons.restaurant_menu_outlined,
                    children: [
                      CustomTextField(
                        controller: _gateClosingController,
                        label: 'Gate Closing Time (HH:mm:ss)',
                        hint: '22:30:00 (10:30 PM)',
                      ),
                      const SizedBox(height: 16),
                      SwitchListTile.adaptive(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Meals / Food Provided', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                        subtitle: const Text('Breakfast, lunch, and dinner included in rent', style: TextStyle(fontSize: 12)),
                        value: _foodAvailable,
                        activeColor: AppColors.primary,
                        onChanged: (v) => setState(() => _foodAvailable = v),
                      ),
                      if (_foodAvailable) ...[
                        const SizedBox(height: 8),
                        const Text('Meal Type', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<String>(
                          value: _foodType,
                          items: const [
                            DropdownMenuItem(value: 'VEG_ONLY', child: Text('Pure Vegetarian')),
                            DropdownMenuItem(value: 'NON_VEG', child: Text('Non-Veg Available')),
                            DropdownMenuItem(value: 'BOTH', child: Text('Veg & Non-Veg Both')),
                          ],
                          onChanged: (v) {
                            if (v != null) setState(() => _foodType = v);
                          },
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Section 4: Amenities
                  _buildSectionCard(
                    title: '4. Amenities Included',
                    icon: Icons.checklist_rtl_rounded,
                    children: [
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _amenityOptions.entries.map((entry) {
                          final isSelected = _selectedAmenityIds.contains(entry.key);
                          return FilterChip(
                            label: Text(entry.value),
                            selected: isSelected,
                            selectedColor: AppColors.primary.withValues(alpha: 0.15),
                            labelStyle: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              color: isSelected ? AppColors.primary : AppColors.textPrimary,
                            ),
                            side: BorderSide(
                              color: isSelected ? AppColors.primary : AppColors.border,
                            ),
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  _selectedAmenityIds.add(entry.key);
                                } else {
                                  _selectedAmenityIds.remove(entry.key);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  CustomButton(
                    text: 'Publish PG Listing',
                    onPressed: _onSubmitPressed,
                    isLoading: isLoading,
                    icon: Icons.check_circle_outline,
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          ...children,
        ],
      ),
    );
  }
}
