import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/bloc/auth_bloc.dart';
import '../../features/auth/views/kyc_upload_screen.dart';
import '../../features/auth/views/login_screen.dart';
import '../../features/auth/views/register_screen.dart';
import '../../features/booking/views/booking_checkout_sheet.dart';
import '../../features/discovery/views/discovery_home_screen.dart';
import '../../features/owner_portal/views/add_property_screen.dart';
import '../../features/owner_portal/views/add_room_screen.dart';
import '../../features/owner_portal/views/owner_dashboard_screen.dart';
import '../../features/property/models/bed_model.dart';
import '../../features/property/models/property_detail_model.dart';
import '../../features/property/models/room_model.dart';
import '../../features/property/views/property_detail_screen.dart';
import '../../features/tenant_portal/views/tenant_dashboard_screen.dart';

class AppRouter {
  static GoRouter createRouter(AuthBloc authBloc) {
    return GoRouter(
      initialLocation: '/discovery',
      routes: [
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
        GoRoute(
          path: '/tenant-portal',
          builder: (context, state) => const TenantDashboardScreen(),
        ),
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
      ],
      errorBuilder: (context, state) => Scaffold(
        body: Center(child: Text('Page not found: ${state.uri}')),
      ),
    );
  }
}
