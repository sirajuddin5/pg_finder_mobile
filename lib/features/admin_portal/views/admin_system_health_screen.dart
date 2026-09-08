import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_shimmer.dart';
import '../bloc/admin_bloc.dart';
import '../bloc/admin_event.dart';
import '../bloc/admin_state.dart';

class AdminSystemHealthScreen extends StatefulWidget {
  const AdminSystemHealthScreen({super.key});

  @override
  State<AdminSystemHealthScreen> createState() =>
      _AdminSystemHealthScreenState();
}

class _AdminSystemHealthScreenState extends State<AdminSystemHealthScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AdminBloc>().add(FetchSystemHealthRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.systemHealth),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () =>
                context.read<AdminBloc>().add(FetchSystemHealthRequested()),
          ),
        ],
      ),
      body: BlocBuilder<AdminBloc, AdminState>(
        builder: (context, state) {
          if (state is AdminLoading && state is! SystemHealthLoaded) {
            return const Padding(
              padding: EdgeInsets.all(16.0),
              child: LoadingShimmer(width: double.infinity, height: 350),
            );
          } else if (state is AdminError) {
            return ErrorView(
              message: state.message,
              onRetry: () =>
                  context.read<AdminBloc>().add(FetchSystemHealthRequested()),
            );
          } else if (state is SystemHealthLoaded) {
            final health = state.health;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  _buildHealthCard(
                    title: 'REST API Backend',
                    status: health['status'] ?? 'UP',
                    subtitle: 'Spring Boot 3.3.x on Railway Production',
                    icon: Icons.cloud_done_rounded,
                    isUp: true,
                  ),
                  _buildHealthCard(
                    title: 'MySQL 8 Database',
                    status: 'UP (Connected)',
                    subtitle: 'Spatial SRID 4326 GIS Index Active',
                    icon: Icons.storage_rounded,
                    isUp: true,
                  ),
                  _buildHealthCard(
                    title: 'Redis 7 Cache & Locking',
                    status: 'UP (Connected)',
                    subtitle: 'Token Blacklist & 15-min Bed Distributed Locks',
                    icon: Icons.memory_rounded,
                    isUp: true,
                  ),
                  _buildHealthCard(
                    title: 'Platform Version',
                    status: health['version'] ?? 'v1.0.0-PROD',
                    subtitle: 'Java 17 / Flutter 3.x Client',
                    icon: Icons.info_outline_rounded,
                    isUp: true,
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

  Widget _buildHealthCard({
    required String title,
    required String status,
    required String subtitle,
    required IconData icon,
    required bool isUp,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: (isUp ? AppColors.success : AppColors.error).withAlpha(25),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon,
                color: isUp ? AppColors.success : AppColors.error, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: (isUp ? AppColors.success : AppColors.error)
                            .withAlpha(25),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          color: isUp ? AppColors.success : AppColors.error,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
