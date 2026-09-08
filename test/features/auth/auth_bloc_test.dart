import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/auth/bloc/auth_bloc.dart';
import 'package:mobile/features/auth/bloc/auth_event.dart';
import 'package:mobile/features/auth/bloc/auth_state.dart';
import 'package:mobile/features/auth/models/auth_tokens_model.dart';
import 'package:mobile/features/auth/models/user_model.dart';
import 'package:mobile/features/auth/repositories/auth_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository mockAuthRepository;
  late AuthBloc authBloc;

  const testUser = UserModel(
    id: 1,
    fullName: 'Test Tenant',
    email: 'tenant@test.com',
    phoneNumber: '9876543210',
    role: 'TENANT',
    status: 'ACTIVE',
  );

  const testTokens = AuthTokensModel(
    accessToken: 'mock_access_token',
    refreshToken: 'mock_refresh_token',
  );

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    authBloc = AuthBloc(authRepository: mockAuthRepository);
  });

  tearDown(() {
    authBloc.close();
  });

  group('AuthBloc Unit Tests', () {
    test('initial state is AuthInitial', () {
      expect(authBloc.state, equals(AuthInitial()));
    });

    blocTest<AuthBloc, AuthState>(
      'emits [Authenticated] when CheckAuthStatusRequested finds valid token and profile',
      build: () {
        when(() => mockAuthRepository.checkAuthStatus()).thenAnswer((_) async => true);
        when(() => mockAuthRepository.getMyProfile()).thenAnswer((_) async => testUser);
        return authBloc;
      },
      act: (bloc) => bloc.add(CheckAuthStatusRequested()),
      expect: () => [
        const Authenticated(user: testUser),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [Unauthenticated] when CheckAuthStatusRequested finds no token',
      build: () {
        when(() => mockAuthRepository.checkAuthStatus()).thenAnswer((_) async => false);
        return authBloc;
      },
      act: (bloc) => bloc.add(CheckAuthStatusRequested()),
      expect: () => [
        Unauthenticated(),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, Authenticated] when LoginSubmitted succeeds',
      build: () {
        when(() => mockAuthRepository.login(
              email: 'tenant@test.com',
              password: 'Password@123',
            )).thenAnswer((_) async => {'user': testUser, 'tokens': testTokens});
        return authBloc;
      },
      act: (bloc) => bloc.add(const LoginSubmitted(
        email: 'tenant@test.com',
        password: 'Password@123',
      )),
      expect: () => [
        AuthLoading(),
        const Authenticated(user: testUser, tokens: testTokens),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthError] when LoginSubmitted fails',
      build: () {
        when(() => mockAuthRepository.login(
              email: 'bad@test.com',
              password: 'wrong',
            )).thenThrow(Exception('Invalid credentials'));
        return authBloc;
      },
      act: (bloc) => bloc.add(const LoginSubmitted(
        email: 'bad@test.com',
        password: 'wrong',
      )),
      expect: () => [
        AuthLoading(),
        const AuthError('Invalid credentials'),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [Unauthenticated] when LogoutRequested succeeds',
      build: () {
        when(() => mockAuthRepository.logout()).thenAnswer((_) async => {});
        return authBloc;
      },
      act: (bloc) => bloc.add(LogoutRequested()),
      expect: () => [
        Unauthenticated(),
      ],
    );
  });
}
