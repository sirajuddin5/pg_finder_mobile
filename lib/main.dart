import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/constants/app_strings.dart';
import 'core/network/dio_client.dart';
import 'core/network/token_storage.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/bloc/auth_bloc.dart';
import 'features/auth/bloc/auth_event.dart';
import 'features/auth/repositories/auth_repository.dart';
import 'features/booking/bloc/booking_bloc.dart';
import 'features/booking/repositories/booking_repository.dart';
import 'features/discovery/bloc/discovery_bloc.dart';
import 'features/discovery/repositories/discovery_repository.dart';
import 'features/property/bloc/property_detail_bloc.dart';
import 'features/property/repositories/property_repository.dart';
import 'features/tenant_portal/bloc/tenant_portal_bloc.dart';
import 'features/tenant_portal/repositories/tenant_portal_repository.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const PgFinderApp());
}

class PgFinderApp extends StatelessWidget {
  
  const PgFinderApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize Repositories
    final dio = DioClient().dio;
    final tokenStorage = TokenStorage();

    final authRepository = AuthRepository(dio: dio, tokenStorage: tokenStorage);
    final discoveryRepository = DiscoveryRepository(dio: dio);
    final propertyRepository = PropertyRepository(dio: dio);
    final bookingRepository = BookingRepository(dio: dio);
    final tenantPortalRepository = TenantPortalRepository(dio: dio);

    final authBloc = AuthBloc(authRepository: authRepository)..add(CheckAuthStatusRequested());
    final router = AppRouter.createRouter(authBloc);

    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>.value(value: authBloc),
        BlocProvider<DiscoveryBloc>(
          create: (_) => DiscoveryBloc(discoveryRepository: discoveryRepository),
        ),
        BlocProvider<PropertyDetailBloc>(
          create: (_) => PropertyDetailBloc(propertyRepository: propertyRepository),
        ),
        BlocProvider<BookingBloc>(
          create: (_) => BookingBloc(bookingRepository: bookingRepository),
        ),
        BlocProvider<TenantPortalBloc>(
          create: (_) => TenantPortalBloc(tenantPortalRepository: tenantPortalRepository),
        ),
      ],
      child: MaterialApp.router(
        title: AppStrings.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        routerConfig: router,
      ),
    );
  }
}
