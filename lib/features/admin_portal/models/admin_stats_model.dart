class AdminStatsModel {
  final int totalProperties;
  final int pendingProperties;
  final int totalUsers;
  final int totalBeds;
  final int occupiedBeds;
  final int openComplaints;
  final double totalRevenue;

  const AdminStatsModel({
    this.totalProperties = 0,
    this.pendingProperties = 0,
    this.totalUsers = 0,
    this.totalBeds = 0,
    this.occupiedBeds = 0,
    this.openComplaints = 0,
    this.totalRevenue = 0.0,
  });

  double get occupancyRate =>
      totalBeds > 0 ? (occupiedBeds / totalBeds) * 100 : 0.0;

  factory AdminStatsModel.fromJson(Map<String, dynamic> json) {
    return AdminStatsModel(
      totalProperties: (json['totalProperties'] as num?)?.toInt() ?? 0,
      pendingProperties: (json['pendingProperties'] as num?)?.toInt() ?? 0,
      totalUsers: (json['totalUsers'] as num?)?.toInt() ?? 0,
      totalBeds: (json['totalBeds'] as num?)?.toInt() ?? 0,
      occupiedBeds: (json['occupiedBeds'] as num?)?.toInt() ?? 0,
      openComplaints: (json['openComplaints'] as num?)?.toInt() ?? 0,
      totalRevenue: (json['totalRevenue'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalProperties': totalProperties,
      'pendingProperties': pendingProperties,
      'totalUsers': totalUsers,
      'totalBeds': totalBeds,
      'occupiedBeds': occupiedBeds,
      'openComplaints': openComplaints,
      'totalRevenue': totalRevenue,
    };
  }
}
