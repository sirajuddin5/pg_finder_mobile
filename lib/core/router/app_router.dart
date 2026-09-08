import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/admin_portal/views/admin_complaints_screen.dart';
import '../../features/admin_portal/views/admin_dashboard_screen.dart';
import '../../features/admin_portal/views/admin_invoice_batch_screen.dart';
import '../../features/admin_portal/views/admin_kyc_verification_screen.dart';
import '../../features/admin_portal/views/admin_pending_properties_screen.dart';
import '../../features/admin_portal/views/admin_system_health_screen.dart';
import '../../features/admin_portal/views/admin_users_screen.dart';
import '../../features/auth/bloc/auth_bloc.dart';
import '../../features/auth/bloc/auth_state.dart';
import '../../features/auth/views/kyc_upload_screen.dart';
import '../../features/auth/views/login_screen.dart';
import '../../features/auth/views/register_screen.dart';
import '../../features/booking/views/booking_checkout_sheet.dart';
import '../../features/discovery/views/discovery_home_screen.dart';
import '../../features/owner_portal/views/add_property_screen.dart';
import '../../features/owner_portal/views/add_room_screen.dart';
import '../../features/owner_portal/views/manage_beds_screen.dart';
import '../../features/owner_portal/views/owner_dashboard_screen.dart';
import '../../features/owner_portal/views/property_invoices_screen.dart';
import '../../features/property/models/bed_model.dart';
import '../../features/property/models/property_detail_model.dart';
import '../../features/property/models/room_model.dart';
import '../../features/property/views/property_detail_screen.dart';
import '../../features/tenant_portal/views/tenant_dashboard_screen.dart';

class AppRouter {
  static GoRouter createRouter(AuthBloc authBloc) {
    return GoRouter(
      initialLocation: '/discovery',
      redirect: (context, state) {
        final authState = authBloc.state;
        final isAuthenticated = authState is Authenticated;
        final userRole = isAuthenticated ? authState.user.role : null;
        final path = state.uri.path;

        final isAuthForm = path == '/login' || path == '/register';

        // 1. If authenticated and on login/register page, route to home based on role
        if (isAuthenticated && isAuthForm) {
          if (userRole == 'ADMIN') return '/admin/dashboard';
          if (userRole == 'OWNER') return '/owner-dashboard';
          return '/discovery';
        }

        // 2. Admin routes protection
        if (path.startsWith('/admin')) {
          if (!isAuthenticated) return '/login?redirect=$path';
          if (userRole != 'ADMIN') return '/discovery';
        }

        // 3. Owner routes protection
        if (path.startsWith('/owner') || path == '/owner-dashboard') {
          if (!isAuthenticated) return '/login?redirect=$path';
          if (userRole != 'OWNER' && userRole != 'ADMIN') return '/discovery';
        }

        // 4. Tenant protected routes
        if (path == '/tenant-portal' || path == '/checkout' || path == '/kyc-upload') {
          if (!isAuthenticated) return '/login?redirect=$path';
        }

        return null;
      },
      routes: [
        // Auth Routes
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/register',
          builder: (context, state) => const RegisterScreen(),
        ),
        GoRoute(
          path: '/kyc-upload',
          builder: (context, state) => const KycUploadScreen(),
        ),

        // Discovery & Details
        GoRoute(
          path: '/discovery',
          builder: (context, state) => const DiscoveryHomeScreen(),
        ),
        GoRoute(
          path: '/property/:id',
          builder: (context, state) {
            final id = int.tryParse(state.pathParameters['id'] ?? '1') ?? 1;
            return PropertyDetailScreen(propertyId: id);
          },
        ),

        // Booking & Checkout
        GoRoute(
          path: '/checkout',
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>? ?? {};
            return BookingCheckoutSheet(
              property: extra['property'] as PropertyDetailModel,
              room: extra['room'] as RoomModel,
              bed: extra['bed'] as BedModel,
            );
          },
        ),

        // Tenant Portal
        GoRoute(
          path: '/tenant-portal',
          builder: (context, state) => const TenantDashboardScreen(),
        ),

        // Owner Portal Routes
        GoRoute(
          path: '/owner-dashboard',
          builder: (context, state) => const OwnerDashboardScreen(),
        ),
        GoRoute(
          path: '/owner/add-property',
          builder: (context, state) => const AddPropertyScreen(),
        ),
        GoRoute(
          path: '/owner/properties/:id/add-room',
          builder: (context, state) {
            final id = int.tryParse(state.pathParameters['id'] ?? '1') ?? 1;
            final extra = state.extra as Map<String, dynamic>? ?? {};
            final title = extra['propertyTitle'] as String? ?? 'Property #$id';
            return AddRoomScreen(propertyId: id, propertyTitle: title);
          },
        ),
        GoRoute(
          path: '/owner/properties/:id/beds',
          builder: (context, state) {
            final id = int.tryParse(state.pathParameters['id'] ?? '1') ?? 1;
            final extra = state.extra as Map<String, dynamic>? ?? {};
            final title = extra['propertyTitle'] as String? ?? 'Property #$id';
            return ManageBedsScreen(propertyId: id, propertyTitle: title);
          },
        ),
        GoRoute(
          path: '/owner/properties/:id/invoices',
          builder: (context, state) {
            final id = int.tryParse(state.pathParameters['id'] ?? '1') ?? 1;
            final extra = state.extra as Map<String, dynamic>? ?? {};
            final title = extra['propertyTitle'] as String? ?? 'Property #$id';
            return PropertyInvoicesScreen(propertyId: id, propertyTitle: title);
          },
        ),

        // Admin Portal Routes
        GoRoute(
          path: '/admin/dashboard',
          builder: (context, state) => const AdminDashboardScreen(),
        ),
        GoRoute(
          path: '/admin/properties/pending',
          builder: (context, state) => const AdminPendingPropertiesScreen(),
        ),
        GoRoute(
          path: '/admin/kyc/pending',
          builder: (context, state) => const AdminKycVerificationScreen(),
        ),
        GoRoute(
          path: '/admin/invoices/batch',
          builder: (context, state) => const AdminInvoiceBatchScreen(),
        ),
        GoRoute(
          path: '/admin/complaints',
          builder: (context, state) => const AdminComplaintsScreen(),
        ),
        GoRoute(
          path: '/admin/users',
          builder: (context, state) => const AdminUsersScreen(),
        ),
        GoRoute(
          path: '/admin/system-health',
          builder: (context, state) => const AdminSystemHealthScreen(),
        ),
      ],
      errorBuilder: (context, state) => Scaffold(
        body: Center(child: Text('Page not found: ${state.uri}')),
      ),
    );
  }
}
