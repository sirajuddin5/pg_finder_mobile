class KycDocumentModel {
  final int id;
  final int userId;
  final String userName;
  final String userEmail;
  final String userRole;
  final String documentType;
  final String documentNumber;
  final String documentUrl;
  final String status;
  final String? rejectionReason;
  final DateTime createdAt;

  KycDocumentModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.userRole,
    required this.documentType,
    required this.documentNumber,
    required this.documentUrl,
    required this.status,
    this.rejectionReason,
    required this.createdAt,
  });

  bool get isPending => status == 'PENDING';
  bool get isVerified => status == 'VERIFIED';
  bool get isRejected => status == 'REJECTED';

  factory KycDocumentModel.fromJson(Map<String, dynamic> json) {
    return KycDocumentModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      userId: (json['userId'] as num?)?.toInt() ?? 0,
      userName: json['userName'] as String? ?? json['fullName'] as String? ?? 'User #${json['userId']}',
      userEmail: json['userEmail'] as String? ?? json['email'] as String? ?? '',
      userRole: json['userRole'] as String? ?? json['role'] as String? ?? 'TENANT',
      documentType: json['documentType'] as String? ?? 'AADHAAR',
      documentNumber: json['documentNumber'] as String? ?? '',
      documentUrl: json['documentUrl'] as String? ?? '',
      status: json['status'] as String? ?? 'PENDING',
      rejectionReason: json['rejectionReason'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userEmail': userEmail,
      'userRole': userRole,
      'documentType': documentType,
      'documentNumber': documentNumber,
      'documentUrl': documentUrl,
      'status': status,
      'rejectionReason': rejectionReason,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
