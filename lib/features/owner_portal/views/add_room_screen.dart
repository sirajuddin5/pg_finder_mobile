import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../bloc/owner_bloc.dart';
import '../bloc/owner_event.dart';
import '../bloc/owner_state.dart';
import '../models/create_room_dto.dart';

class AddRoomScreen extends StatefulWidget {
  final int propertyId;
  final String propertyTitle;

  const AddRoomScreen({
    super.key,
    required this.propertyId,
    required this.propertyTitle,
  });

  @override
  State<AddRoomScreen> createState() => _AddRoomScreenState();
}

class _AddRoomScreenState extends State<AddRoomScreen> {
  final _formKey = GlobalKey<FormState>();
  final _roomNumberController = TextEditingController();
  final _floorController = TextEditingController(text: '1');
  final _rentController = TextEditingController();
  final _depositController = TextEditingController();

  String _sharingType = 'DOUBLE';
  bool _hasAc = true;
  bool _hasAttachedBathroom = true;
  bool _hasBalcony = false;
  bool _autoGenerateBeds = true;

  @override
  void dispose() {
    _roomNumberController.dispose();
    _floorController.dispose();
    _rentController.dispose();
    _depositController.dispose();
    super.dispose();
  }

  void _onSubmitPressed() {
    if (_formKey.currentState?.validate() ?? false) {
      final rent = double.tryParse(_rentController.text) ?? 0.0;
      final deposit = double.tryParse(_depositController.text) ?? (rent * 2);

      final dto = CreateRoomDto(
        roomNumber: _roomNumberController.text.trim(),
        floorNumber: int.tryParse(_floorController.text) ?? 1,
        sharingType: _sharingType,
        baseRentMonthly: rent,
        securityDeposit: deposit,
        hasAc: _hasAc,
        hasAttachedBathroom: _hasAttachedBathroom,
        hasBalcony: _hasBalcony,
        autoGenerateBeds: _autoGenerateBeds,
      );

      context.read<OwnerBloc>().add(
            CreateRoomSubmitted(
              propertyId: widget.propertyId,
              dto: dto,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Add Room • ${widget.propertyTitle}'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocConsumer<OwnerBloc, OwnerState>(
        listener: (context, state) {
          if (state is RoomCreatedSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Room ${state.room.roomNumber} added with ${state.room.beds.length} beds!'),
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
                  Container(
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
                            Expanded(
                              child: CustomTextField(
                                controller: _roomNumberController,
                                label: 'Room Number',
                                hint: 'e.g. 101, 204',
                                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: CustomTextField(
                                controller: _floorController,
                                label: 'Floor Number',
                                hint: '1',
                                keyboardType: TextInputType.number,
                                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Text('Sharing Configuration', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: _sharingType,
                          items: const [
                            DropdownMenuItem(value: 'SINGLE', child: Text('Single Sharing (Private Room)')),
                            DropdownMenuItem(value: 'DOUBLE', child: Text('Double Sharing (2 Beds)')),
                            DropdownMenuItem(value: 'TRIPLE', child: Text('Triple Sharing (3 Beds)')),
                            DropdownMenuItem(value: 'FOUR_PLUS', child: Text('4+ Sharing (Dormitory)')),
                          ],
                          onChanged: (v) {
                            if (v != null) setState(() => _sharingType = v);
                          },
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: CustomTextField(
                                controller: _rentController,
                                label: 'Monthly Rent (₹)',
                                hint: '10000',
                                keyboardType: TextInputType.number,
                                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: CustomTextField(
                                controller: _depositController,
                                label: 'Security Deposit (₹)',
                                hint: '20000',
                                keyboardType: TextInputType.number,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Divider(),
                        SwitchListTile.adaptive(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Air Conditioning (AC) Fitted', style: TextStyle(fontSize: 14)),
                          value: _hasAc,
                          activeColor: AppColors.primary,
                          onChanged: (v) => setState(() => _hasAc = v),
                        ),
                        SwitchListTile.adaptive(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Attached Bathroom Inside Room', style: TextStyle(fontSize: 14)),
                          value: _hasAttachedBathroom,
                          activeColor: AppColors.primary,
                          onChanged: (v) => setState(() => _hasAttachedBathroom = v),
                        ),
                        SwitchListTile.adaptive(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Private Balcony', style: TextStyle(fontSize: 14)),
                          value: _hasBalcony,
                          activeColor: AppColors.primary,
                          onChanged: (v) => setState(() => _hasBalcony = v),
                        ),
                        SwitchListTile.adaptive(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Auto-Generate Bed Identifiers', style: TextStyle(fontSize: 14)),
                          subtitle: const Text('Automatically labels beds like 101-A, 101-B', style: TextStyle(fontSize: 12)),
                          value: _autoGenerateBeds,
                          activeColor: AppColors.primary,
                          onChanged: (v) => setState(() => _autoGenerateBeds = v),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  CustomButton(
                    text: 'Save & Add Room',
                    onPressed: _onSubmitPressed,
                    isLoading: isLoading,
                    icon: Icons.add_home_outlined,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
