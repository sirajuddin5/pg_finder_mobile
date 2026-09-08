import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_shimmer.dart';
import '../bloc/discovery_bloc.dart';
import '../bloc/discovery_event.dart';
import '../bloc/discovery_state.dart';
import '../models/search_criteria_model.dart';
import 'filter_bottom_sheet.dart';
import 'property_card.dart';

class DiscoveryHomeScreen extends StatefulWidget {
  const DiscoveryHomeScreen({super.key});

  @override
  State<DiscoveryHomeScreen> createState() => _DiscoveryHomeScreenState();
}

class _DiscoveryHomeScreenState extends State<DiscoveryHomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  double _radiusKm = 5.0;

  @override
  void initState() {
    super.initState();
    // Load default nearby properties
    context.read<DiscoveryBloc>().add(
          const SearchPropertiesRequested(criteria: SearchCriteriaModel()),
        );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openFilterSheet(SearchCriteriaModel currentCriteria) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FilterBottomSheet(
        initialCriteria: currentCriteria,
        onApply: (updated) {
          context.read<DiscoveryBloc>().add(FilterCriteriaUpdated(updated));
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.location_on, color: AppColors.primary, size: 16),
                const SizedBox(width: 4),
                Text(
                  'Bengaluru, Karnataka',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Icon(Icons.keyboard_arrow_down, size: 16, color: AppColors.textSecondary),
              ],
            ),
            const Text(
              'Explore Verified PGs',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle_outlined, size: 28),
            onPressed: () => context.push('/tenant-portal'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Search & Filter Bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: TextField(
                          controller: _searchController,
                          decoration: const InputDecoration(
                            hintText: AppStrings.searchHint,
                            hintStyle: TextStyle(fontSize: 13, color: AppColors.textMuted),
                            prefixIcon: Icon(Icons.search, size: 20, color: AppColors.textMuted),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    BlocBuilder<DiscoveryBloc, DiscoveryState>(
                      builder: (context, state) {
                        final criteria = state is DiscoveryLoaded
                            ? state.currentCriteria
                            : const SearchCriteriaModel();

                        return InkWell(
                          onTap: () => _openFilterSheet(criteria),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            height: 48,
                            width: 48,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.tune_rounded, color: Colors.white, size: 20),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Radius Slider Control
                Row(
                  children: [
                    const Icon(Icons.radar_rounded, size: 16, color: AppColors.primary),
                    const SizedBox(width: 6),
                    Text(
                      'Radius: ${_radiusKm.toInt()} km',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Expanded(
                      child: SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 3,
                          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                          overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                        ),
                        child: Slider(
                          value: _radiusKm,
                          min: 1.0,
                          max: 20.0,
                          divisions: 19,
                          activeColor: AppColors.primary,
                          onChanged: (v) {
                            setState(() => _radiusKm = v);
                          },
                          onChangeEnd: (v) {
                            context.read<DiscoveryBloc>().add(RadiusChanged(v));
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Results
          Expanded(
            child: BlocBuilder<DiscoveryBloc, DiscoveryState>(
              builder: (context, state) {
                if (state is DiscoveryLoading || state is DiscoveryInitial) {
                  return LoadingShimmer.propertyCardList();
                } else if (state is DiscoveryError) {
                  return ErrorView(
                    message: state.message,
                    onRetry: () {
                      context.read<DiscoveryBloc>().add(
                            SearchPropertiesRequested(
                              criteria: SearchCriteriaModel(radiusKm: _radiusKm),
                            ),
                          );
                    },
                  );
                } else if (state is DiscoveryLoaded) {
                  if (state.properties.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off_rounded, size: 64, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            const Text(
                              'No PGs found in this radius',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Try increasing the search radius or relaxing some filters.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: state.properties.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final prop = state.properties[index];
                      return PropertyCard(
                        property: prop,
                        onTap: () {
                          context.push('/property/${prop.id}');
                        },
                      );
                    },
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}
