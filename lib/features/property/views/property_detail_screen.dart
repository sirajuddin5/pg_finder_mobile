import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_shimmer.dart';
import '../bloc/property_detail_bloc.dart';
import '../bloc/property_detail_event.dart';
import '../bloc/property_detail_state.dart';
import 'room_bed_matrix_widget.dart';

class PropertyDetailScreen extends StatefulWidget {
  final int propertyId;

  const PropertyDetailScreen({super.key, required this.propertyId});

  @override
  State<PropertyDetailScreen> createState() => _PropertyDetailScreenState();
}

class _PropertyDetailScreenState extends State<PropertyDetailScreen> {
  @override
  void initState() {
    super.initState();
    context.read<PropertyDetailBloc>().add(LoadPropertyDetailRequested(widget.propertyId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocBuilder<PropertyDetailBloc, PropertyDetailState>(
        builder: (context, state) {
          if (state is PropertyDetailLoading || state is PropertyDetailInitial) {
            return const Scaffold(
              body: Center(child: LoadingShimmer(width: double.infinity, height: double.infinity)),
            );
          } else if (state is PropertyDetailError) {
            return Scaffold(
              appBar: AppBar(),
              body: ErrorView(
                message: state.message,
                onRetry: () => context.read<PropertyDetailBloc>().add(
                      LoadPropertyDetailRequested(widget.propertyId),
                    ),
              ),
            );
          } else if (state is PropertyDetailLoaded) {
            final property = state.property;
            final selectedBed = state.selectedBed;
            final selectedRoom = state.selectedRoom;

            return CustomScrollView(
              slivers: [
                // Collapsing Image AppBar
                SliverAppBar(
                  expandedHeight: 280,
                  pinned: true,
                  leading: CircleAvatar(
                    backgroundColor: Colors.black.withValues(alpha: 0.5),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
                      onPressed: () => context.pop(),
                    ),
                  ),
                  flexibleSpace: FlexibleSpaceBar(
                    background: property.images.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: property.images.first,
                            fit: BoxFit.cover,
                            errorWidget: (_, __, ___) => Container(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              child: const Center(child: Icon(Icons.apartment_rounded, size: 64, color: AppColors.primary)),
                            ),
                          )
                        : Container(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            child: const Center(child: Icon(Icons.apartment_rounded, size: 64, color: AppColors.primary)),
                          ),
                  ),
                ),
                // Content Body
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title & Type
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                property.title,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            if (property.isVerified)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.successBackground,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(Icons.verified, size: 14, color: AppColors.success),
                                    SizedBox(width: 4),
                                    Text(
                                      'Verified',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.success,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.location_on_outlined, size: 16, color: AppColors.textSecondary),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                '${property.addressLine}, ${property.city} - ${property.pincode}',
                                style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // About
                        const Text(
                          'About this Property',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          property.description,
                          style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.5),
                        ),
                        const SizedBox(height: 24),
                        // Amenities Section
                        if (property.amenities.isNotEmpty) ...[
                          const Text(
                            AppStrings.amenities,
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: property.amenities.map((a) {
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.check_circle_outline, size: 16, color: AppColors.primary),
                                    const SizedBox(width: 6),
                                    Text(a, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 28),
                        ],
                        // Room & Bed Selection Matrix
                        const Text(
                          'Available Rooms & Beds',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: 12),
                        RoomBedMatrixWidget(
                          rooms: property.rooms,
                          selectedRoom: selectedRoom,
                          selectedBed: selectedBed,
                          onRoomSelected: (r) => context.read<PropertyDetailBloc>().add(RoomSelected(r)),
                          onBedSelected: (b) => context.read<PropertyDetailBloc>().add(BedSelected(b)),
                        ),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
      bottomSheet: BlocBuilder<PropertyDetailBloc, PropertyDetailState>(
        builder: (context, state) {
          if (state is PropertyDetailLoaded && state.selectedBed != null && state.selectedRoom != null) {
            final bed = state.selectedBed!;
            final room = state.selectedRoom!;
            final currencyFormatter = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

            return Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 16,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bed ${bed.bedIdentifier} Selected',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                        ),
                        Text(
                          '${currencyFormatter.format(room.baseRentMonthly)}/mo',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: CustomButton(
                        text: bed.isVacant ? AppStrings.bookBed : 'Bed ${bed.status}',
                        onPressed: bed.isVacant
                            ? () {
                                context.push('/checkout', extra: {
                                  'property': state.property,
                                  'room': room,
                                  'bed': bed,
                                });
                              }
                            : null,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
