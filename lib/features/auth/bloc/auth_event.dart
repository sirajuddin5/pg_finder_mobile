import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class CheckAuthStatusRequested extends AuthEvent {}

class LoginSubmitted extends AuthEvent {
  final String email;
  final String password;

  const LoginSubmitted({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class RegisterSubmitted extends AuthEvent {
  final String fullName;
  final String email;
  final String phoneNumber;
  final String password;
  final String role;

  const RegisterSubmitted({
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.password,
    required this.role,
  });

  @override
  List<Object?> get props => [fullName, email, phoneNumber, password, role];
}

class KycUploaded extends AuthEvent {
  final String documentType;
  final String documentNumber;
  final String documentUrl;

  const KycUploaded({
    required this.documentType,
    required this.documentNumber,
    required this.documentUrl,
  });

  @override
  List<Object?> get props => [documentType, documentNumber, documentUrl];
}

class LogoutRequested extends AuthEvent {}
