class AdminUserModel {
  final int id;
  final String fullName;
  final String email;
  final String phoneNumber;
  final String role;
  final bool active;
  final String? kycStatus;
  final DateTime createdAt;

  AdminUserModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.role,
    this.active = true,
    this.kycStatus,
    required this.createdAt,
  });

  factory AdminUserModel.fromJson(Map<String, dynamic> json) {
    return AdminUserModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      fullName: json['fullName'] as String? ?? 'User',
      email: json['email'] as String? ?? '',
      phoneNumber: json['phoneNumber'] as String? ?? '',
      role: json['role'] as String? ?? 'TENANT',
      active: json['active'] as bool? ?? true,
      kycStatus: json['kycStatus'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'phoneNumber': phoneNumber,
      'role': role,
      'active': active,
      'kycStatus': kycStatus,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
