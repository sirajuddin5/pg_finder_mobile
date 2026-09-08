import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_shimmer.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_event.dart';
import '../bloc/admin_bloc.dart';
import '../bloc/admin_event.dart';
import '../bloc/admin_state.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AdminBloc>().add(FetchAdminDashboardRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.adminConsole),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh Dashboard',
            onPressed: () =>
                context.read<AdminBloc>().add(FetchAdminDashboardRequested()),
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Sign Out',
            onPressed: () {
              context.read<AuthBloc>().add(LogoutRequested());
              context.go('/login');
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: BlocBuilder<AdminBloc, AdminState>(
        builder: (context, state) {
          if (state is AdminLoading && state is! AdminDashboardLoaded) {
            return const Padding(
              padding: EdgeInsets.all(16.0),
              child: LoadingShimmer(width: double.infinity, height: 400),
            );
          } else if (state is AdminError) {
            return ErrorView(
              message: state.message,
              onRetry: () =>
                  context.read<AdminBloc>().add(FetchAdminDashboardRequested()),
            );
          } else if (state is AdminDashboardLoaded) {
            final stats = state.stats;
            return RefreshIndicator(
              onRefresh: () async {
                context.read<AdminBloc>().add(FetchAdminDashboardRequested());
              },
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  // System Status Banner
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.success.withAlpha(25),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.success.withAlpha(75)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.check_circle_rounded,
                            color: AppColors.success, size: 20),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Platform Live • MySQL 8 Spatial & Redis 7 Active',
                            style: TextStyle(
                              color: AppColors.success,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // KPI Grid
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.4,
                    children: [
                      _buildMetricCard(
                        title: 'Active PGs',
                        value: '${stats.totalProperties}',
                        icon: Icons.apartment_rounded,
                        color: AppColors.primary,
                      ),
                      _buildMetricCard(
                        title: 'Pending Approvals',
                        value: '${stats.pendingProperties}',
                        icon: Icons.hourglass_top_rounded,
                        color: stats.pendingProperties > 0
                            ? AppColors.warning
                            : AppColors.success,
                      ),
                      _buildMetricCard(
                        title: 'Total Capacity',
                        value: '${stats.totalBeds} Beds',
                        icon: Icons.bed_rounded,
                        color: AppColors.secondary,
                      ),
                      _buildMetricCard(
                        title: 'Occupancy Rate',
                        value: '${stats.occupancyRate.toStringAsFixed(1)}%',
                        icon: Icons.pie_chart_rounded,
                        color: AppColors.info,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Navigation Actions Header
                  const Text(
                    'Administrative Controls',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Navigation Tiles
                  _buildNavTile(
                    context,
                    title: 'PG Property Approvals Queue',
                    subtitle: 'Review, inspect, approve, or reject new PG submissions',
                    icon: Icons.verified_user_rounded,
                    color: AppColors.primary,
                    badgeCount: stats.pendingProperties,
                    onTap: () => context.push('/admin/properties/pending'),
                  ),
                  _buildNavTile(
                    context,
                    title: 'Global KYC Verification',
                    subtitle: 'Audit government IDs & identity verification submissions',
                    icon: Icons.badge_rounded,
                    color: AppColors.secondary,
                    onTap: () => context.push('/admin/kyc/pending'),
                  ),
                  _buildNavTile(
                    context,
                    title: 'Monthly Rent Invoicing Engine',
                    subtitle: 'Trigger batch rent generation for active leases',
                    icon: Icons.receipt_long_rounded,
                    color: AppColors.accent,
                    onTap: () => context.push('/admin/invoices/batch'),
                  ),
                  _buildNavTile(
                    context,
                    title: 'Platform Complaint & SLA Monitor',
                    subtitle: 'Oversight on maintenance tickets and SLA resolutions',
                    icon: Icons.build_circle_rounded,
                    color: AppColors.warning,
                    badgeCount: stats.openComplaints,
                    onTap: () => context.push('/admin/complaints'),
                  ),
                  _buildNavTile(
                    context,
                    title: 'User Account Directory',
                    subtitle: 'Inspect registered tenants, owners, and permissions',
                    icon: Icons.people_rounded,
                    color: AppColors.info,
                    onTap: () => context.push('/admin/users'),
                  ),
                  _buildNavTile(
                    context,
                    title: 'System Health & Telemetry',
                    subtitle: 'Check API, database, and Redis distributed locks',
                    icon: Icons.health_and_safety_rounded,
                    color: AppColors.success,
                    onTap: () => context.push('/admin/system-health'),
                  ),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMuted,
                ),
              ),
              Icon(icon, color: color, size: 20),
            ],
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    int? badgeCount,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withAlpha(25),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            if (badgeCount != null && badgeCount > 0)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.error,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$badgeCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
        ),
        trailing: const Icon(Icons.arrow_forward_ios_rounded,
            size: 14, color: AppColors.textMuted),
        onTap: onTap,
      ),
    );
  }
}
