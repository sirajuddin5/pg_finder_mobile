import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_shimmer.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_event.dart';
import '../bloc/tenant_portal_bloc.dart';
import '../bloc/tenant_portal_event.dart';
import '../bloc/tenant_portal_state.dart';
import 'active_stay_tab.dart';
import 'complaint_logger_tab.dart';
import 'invoice_list_tab.dart';

class TenantDashboardScreen extends StatefulWidget {
  const TenantDashboardScreen({super.key});

  @override
  State<TenantDashboardScreen> createState() => _TenantDashboardScreenState();
}

class _TenantDashboardScreenState extends State<TenantDashboardScreen> {
  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    context.read<TenantPortalBloc>().add(LoadTenantDashboardRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.tenantPortal),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.go('/discovery'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.badge_outlined, size: 22),
            tooltip: 'KYC Document',
            onPressed: () => context.push('/kyc-upload'),
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded, size: 22),
            tooltip: 'Sign Out',
            onPressed: () {
              context.read<AuthBloc>().add(LogoutRequested());
              context.go('/login');
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: BlocConsumer<TenantPortalBloc, TenantPortalState>(
        listener: (context, state) {
          if (state is InvoicePaymentSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Invoice ${state.invoice.invoiceNumber} paid successfully!'),
                backgroundColor: AppColors.success,
                behavior: SnackBarBehavior.floating,
              ),
            );
          } else if (state is ComplaintSubmissionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Maintenance ticket #${state.complaint.id} logged successfully!'),
                backgroundColor: AppColors.success,
                behavior: SnackBarBehavior.floating,
              ),
            );
          } else if (state is TenantPortalError) {
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
          if (state is TenantPortalLoading || state is TenantPortalInitial) {
            return const Center(child: LoadingShimmer(width: double.infinity, height: 400));
          } else if (state is TenantPortalError) {
            return ErrorView(
              message: state.message,
              onRetry: () => context.read<TenantPortalBloc>().add(LoadTenantDashboardRequested()),
            );
          } else if (state is TenantDashboardLoaded) {
            final activeBooking = state.activeStay;
            final propertyId = activeBooking?.bedId; // or property ID

            return IndexedStack(
              index: _selectedTabIndex,
              children: [
                ActiveStayTab(activeStay: activeBooking),
                InvoiceListTab(invoices: state.invoices),
                ComplaintLoggerTab(
                  complaints: state.complaints,
                  propertyId: propertyId != null ? 1 : null, // Default fallback
                ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedTabIndex,
        onTap: (index) => setState(() => _selectedTabIndex = index),
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textMuted,
        backgroundColor: Colors.white,
        elevation: 8,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home_rounded),
            label: AppStrings.activeStay,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            activeIcon: Icon(Icons.receipt_long_rounded),
            label: AppStrings.rentInvoices,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.build_outlined),
            activeIcon: Icon(Icons.build_rounded),
            label: AppStrings.complaints,
          ),
        ],
      ),
    );
  }
}
