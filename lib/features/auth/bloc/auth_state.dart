import 'package:equatable/equatable.dart';
import '../models/auth_tokens_model.dart';
import '../models/user_model.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class Authenticated extends AuthState {
  final UserModel user;
  final AuthTokensModel? tokens;

  const Authenticated({required this.user, this.tokens});

  @override
  List<Object?> get props => [user, tokens];
}

class Unauthenticated extends AuthState {}

class KycUploadSuccess extends AuthState {
  final String message;

  const KycUploadSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}
