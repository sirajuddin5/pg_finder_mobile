import 'package:equatable/equatable.dart';

class ComplaintModel extends Equatable {
  final int id;
  final int? propertyId;
  final String? propertyTitle;
  final String category;
  final String title;
  final String description;
  final String? attachmentUrl;
  final String status;
  final String createdAt;

  const ComplaintModel({
    required this.id,
    this.propertyId,
    this.propertyTitle,
    required this.category,
    required this.title,
    required this.description,
    this.attachmentUrl,
    required this.status,
    required this.createdAt,
  });

  factory ComplaintModel.fromJson(Map<String, dynamic> json) {
    return ComplaintModel(
      id: json['id'] as int,
      propertyId: json['propertyId'] as int?,
      propertyTitle: json['propertyTitle'] as String?,
      category: json['category'] as String? ?? 'OTHER',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      attachmentUrl: json['attachmentUrl'] as String?,
      status: json['status'] as String? ?? 'OPEN',
      createdAt: json['createdAt'] as String? ?? '',
    );
  }

  bool get isOpen => status == 'OPEN';
  bool get isInProgress => status == 'IN_PROGRESS';
  bool get isResolved => status == 'RESOLVED';
  bool get isClosed => status == 'CLOSED';

  @override
  List<Object?> get props => [id, propertyId, category, title, description, status, createdAt];
}
