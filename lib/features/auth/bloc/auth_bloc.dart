import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/auth_tokens_model.dart';
import '../models/user_model.dart';
import '../repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(AuthInitial()) {
    on<CheckAuthStatusRequested>(_onCheckAuthStatus);
    on<LoginSubmitted>(_onLogin);
    on<RegisterSubmitted>(_onRegister);
    on<KycUploaded>(_onUploadKyc);
    on<LogoutRequested>(_onLogout);
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatusRequested event,
    Emitter<AuthState> emit,
  ) async {
    final hasToken = await _authRepository.checkAuthStatus();
    if (hasToken) {
      try {
        final user = await _authRepository.getMyProfile();
        emit(Authenticated(user: user));
      } catch (_) {
        emit(Unauthenticated());
      }
    } else {
      emit(Unauthenticated());
    }
  }

  Future<void> _onLogin(
    LoginSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final result = await _authRepository.login(
        email: event.email,
        password: event.password,
      );
      emit(Authenticated(
        user: result['user'] as UserModel,
        tokens: result['tokens'] as AuthTokensModel,
      ));
    } catch (e) {
      emit(AuthError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onRegister(
    RegisterSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final result = await _authRepository.register(
        fullName: event.fullName,
        email: event.email,
        phoneNumber: event.phoneNumber,
        password: event.password,
        role: event.role,
      );
      emit(Authenticated(
        user: result['user'] as UserModel,
        tokens: result['tokens'] as AuthTokensModel,
      ));
    } catch (e) {
      emit(AuthError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onUploadKyc(
    KycUploaded event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await _authRepository.uploadKyc(
        documentType: event.documentType,
        documentNumber: event.documentNumber,
        documentUrl: event.documentUrl,
      );
      final user = await _authRepository.getMyProfile();
      emit(Authenticated(user: user));
    } catch (e) {
      emit(AuthError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onLogout(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _authRepository.logout();
    emit(Unauthenticated());
  }
}
