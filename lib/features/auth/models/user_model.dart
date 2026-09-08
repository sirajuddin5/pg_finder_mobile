import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final int id;
  final String fullName;
  final String email;
  final String phoneNumber;
  final String role;
  final String status;
  final String? profileImageUrl;

  const UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.role,
    required this.status,
    this.profileImageUrl,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      fullName: json['fullName'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phoneNumber: json['phoneNumber'] as String? ?? '',
      role: json['role'] as String? ?? 'TENANT',
      status: json['status'] as String? ?? 'ACTIVE',
      profileImageUrl: json['profileImageUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'phoneNumber': phoneNumber,
      'role': role,
      'status': status,
      'profileImageUrl': profileImageUrl,
    };
  }

  bool get isOwner => role == 'OWNER';
  bool get isTenant => role == 'TENANT';
  bool get isAdmin => role == 'ADMIN';

  @override
  List<Object?> get props => [id, fullName, email, phoneNumber, role, status, profileImageUrl];
}
