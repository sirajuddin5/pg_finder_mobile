import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_shimmer.dart';
import '../bloc/admin_bloc.dart';
import '../bloc/admin_event.dart';
import '../bloc/admin_state.dart';

class AdminComplaintsScreen extends StatefulWidget {
  const AdminComplaintsScreen({super.key});

  @override
  State<AdminComplaintsScreen> createState() => _AdminComplaintsScreenState();
}

class _AdminComplaintsScreenState extends State<AdminComplaintsScreen> {
  String _selectedStatus = 'ALL';

  @override
  void initState() {
    super.initState();
    context.read<AdminBloc>().add(FetchAllComplaintsRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.globalComplaints),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () =>
                context.read<AdminBloc>().add(FetchAllComplaintsRequested()),
          ),
        ],
      ),
      body: BlocBuilder<AdminBloc, AdminState>(
        builder: (context, state) {
          if (state is AdminLoading && state is! AllComplaintsLoaded) {
            return const Padding(
              padding: EdgeInsets.all(16.0),
              child: LoadingShimmer(width: double.infinity, height: 350),
            );
          } else if (state is AdminError) {
            return ErrorView(
              message: state.message,
              onRetry: () =>
                  context.read<AdminBloc>().add(FetchAllComplaintsRequested()),
            );
          } else if (state is AllComplaintsLoaded) {
            var tickets = state.complaints;

            if (_selectedStatus != 'ALL') {
              tickets = tickets.where((t) => t.status == _selectedStatus).toList();
            }

            return Column(
              children: [
                // Filter Tabs
                Container(
                  color: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      _buildStatusChip('ALL', 'All'),
                      const SizedBox(width: 8),
                      _buildStatusChip('OPEN', 'Open'),
                      const SizedBox(width: 8),
                      _buildStatusChip('IN_PROGRESS', 'In Progress'),
                      const SizedBox(width: 8),
                      _buildStatusChip('RESOLVED', 'Resolved'),
                    ],
                  ),
                ),
                Expanded(
                  child: tickets.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.task_alt_rounded,
                                  size: 64,
                                  color: AppColors.textMuted.withAlpha(150)),
                              const SizedBox(height: 16),
                              const Text(
                                'No Maintenance Tickets',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: () async {
                            context
                                .read<AdminBloc>()
                                .add(FetchAllComplaintsRequested());
                          },
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16.0),
                            itemCount: tickets.length,
                            itemBuilder: (context, index) {
                              final ticket = tickets[index];
                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withAlpha(6),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(14.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              _buildCategoryIcon(ticket.category),
                                              const SizedBox(width: 8),
                                              Text(
                                                ticket.category.replaceAll('_', ' '),
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                  color: AppColors.textPrimary,
                                                ),
                                              ),
                                            ],
                                          ),
                                          _buildStatusBadge(ticket.status),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        ticket.description,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                      const Divider(height: 20),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            ticket.propertyTitle != null
                                                ? '${ticket.propertyTitle} (ID #${ticket.propertyId})'
                                                : 'Property #${ticket.propertyId ?? "-"}',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: AppColors.textMuted,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          Text(
                                            ticket.createdAt.length >= 10
                                                ? ticket.createdAt.substring(0, 10)
                                                : ticket.createdAt,
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: AppColors.textMuted,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildStatusChip(String value, String label) {
    final isSelected = _selectedStatus == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) setState(() => _selectedStatus = value);
      },
      selectedColor: AppColors.primary.withAlpha(30),
      labelStyle: TextStyle(
        color: isSelected ? AppColors.primary : AppColors.textSecondary,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 12,
      ),
    );
  }

  Widget _buildCategoryIcon(String category) {
    IconData icon = Icons.build_rounded;
    Color color = AppColors.primary;

    if (category.contains('PLUMB')) {
      icon = Icons.water_drop_rounded;
      color = AppColors.info;
    } else if (category.contains('ELECTR')) {
      icon = Icons.bolt_rounded;
      color = AppColors.warning;
    } else if (category.contains('WIFI')) {
      icon = Icons.wifi_rounded;
      color = AppColors.secondary;
    }

    return Icon(icon, color: color, size: 18);
  }

  Widget _buildStatusBadge(String status) {
    Color bg = AppColors.warning.withAlpha(25);
    Color fg = AppColors.warning;

    if (status == 'RESOLVED' || status == 'CLOSED') {
      bg = AppColors.success.withAlpha(25);
      fg = AppColors.success;
    } else if (status == 'OPEN') {
      bg = AppColors.error.withAlpha(25);
      fg = AppColors.error;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status,
        style: TextStyle(color: fg, fontWeight: FontWeight.bold, fontSize: 11),
      ),
    );
  }
}
