import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_shimmer.dart';
import '../../property/models/bed_model.dart';
import '../../property/models/room_model.dart';
import '../bloc/owner_bloc.dart';
import '../bloc/owner_event.dart';
import '../bloc/owner_state.dart';

class ManageBedsScreen extends StatefulWidget {
  final int propertyId;
  final String propertyTitle;

  const ManageBedsScreen({
    super.key,
    required this.propertyId,
    required this.propertyTitle,
  });

  @override
  State<ManageBedsScreen> createState() => _ManageBedsScreenState();
}

class _ManageBedsScreenState extends State<ManageBedsScreen> {
  @override
  void initState() {
    super.initState();
    context
        .read<OwnerBloc>()
        .add(LoadPropertyBedsRequested(propertyId: widget.propertyId));
  }

  void _showBedStatusModal(BuildContext context, BedModel bed) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetCtx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Update Bed ${bed.bedIdentifier} Status',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Current Status: ${bed.status}',
                style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
              ),
              const Divider(height: 24),
              _buildStatusOption(sheetCtx, bed, 'VACANT', '🟢 Vacant (Available for booking)', AppColors.success),
              _buildStatusOption(sheetCtx, bed, 'OCCUPIED', '🔵 Occupied (Taken by offline tenant)', AppColors.primary),
              _buildStatusOption(sheetCtx, bed, 'MAINTENANCE', '🟠 Maintenance (Under repair / cleaning)', AppColors.warning),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusOption(
    BuildContext sheetCtx,
    BedModel bed,
    String status,
    String label,
    Color color,
  ) {
    final isCurrent = bed.status == status;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        isCurrent ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
        color: isCurrent ? color : AppColors.textMuted,
      ),
      title: Text(
        label,
        style: TextStyle(
          fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
          color: isCurrent ? color : AppColors.textPrimary,
          fontSize: 14,
        ),
      ),
      onTap: () {
        Navigator.pop(sheetCtx);
        if (!isCurrent) {
          context.read<OwnerBloc>().add(
                UpdateBedStatusRequested(
                  bedId: bed.id,
                  status: status,
                  propertyId: widget.propertyId,
                ),
              );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('${AppStrings.manageBeds} • ${widget.propertyTitle}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => context
                .read<OwnerBloc>()
                .add(LoadPropertyBedsRequested(propertyId: widget.propertyId)),
          ),
        ],
      ),
      body: BlocConsumer<OwnerBloc, OwnerState>(
        listener: (context, state) {
          if (state is BedStatusUpdatedSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.success,
                behavior: SnackBarBehavior.floating,
              ),
            );
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
          if (state is OwnerLoading && state is! PropertyBedsLoaded) {
            return const Padding(
              padding: EdgeInsets.all(16.0),
              child: LoadingShimmer(width: double.infinity, height: 350),
            );
          } else if (state is OwnerError) {
            return ErrorView(
              message: state.message,
              onRetry: () => context
                  .read<OwnerBloc>()
                  .add(LoadPropertyBedsRequested(propertyId: widget.propertyId)),
            );
          } else if (state is PropertyBedsLoaded) {
            final rooms = state.property.rooms;

            if (rooms.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.meeting_room_outlined,
                        size: 64, color: AppColors.textMuted.withAlpha(150)),
                    const SizedBox(height: 16),
                    const Text(
                      'No Rooms Added Yet',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Add rooms to configure bed availability.',
                      style: TextStyle(color: AppColors.textMuted),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: rooms.length,
              itemBuilder: (context, index) {
                final room = rooms[index];
                return _buildRoomCard(context, room);
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildRoomCard(BuildContext context, RoomModel room) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.meeting_room_rounded,
                        color: AppColors.primary, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Room ${room.roomNumber}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                Text(
                  '₹${room.baseRentMonthly.toInt()}/mo',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '${room.sharingType.replaceAll('_', ' ')} • Floor ${room.floorNumber} • ${room.hasAc ? "AC" : "Non-AC"}',
              style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
            const Divider(height: 20),
            const Text(
              'Beds Inventory (Tap to toggle status):',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: room.beds.map((bed) {
                return InkWell(
                  onTap: () => _showBedStatusModal(context, bed),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: _getBedColor(bed.status).withAlpha(20),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: _getBedColor(bed.status).withAlpha(100),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.bed_rounded,
                            size: 16, color: _getBedColor(bed.status)),
                        const SizedBox(width: 6),
                        Text(
                          'Bed ${bed.bedIdentifier}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: _getBedColor(bed.status),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '(${bed.status})',
                          style: TextStyle(
                            fontSize: 10,
                            color: _getBedColor(bed.status),
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
    );
  }

  Color _getBedColor(String status) {
    if (status == 'VACANT') return AppColors.success;
    if (status == 'OCCUPIED') return AppColors.primary;
    return AppColors.warning;
  }
}
