import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../bloc/tenant_portal_bloc.dart';
import '../bloc/tenant_portal_event.dart';
import '../models/complaint_model.dart';

class ComplaintLoggerTab extends StatelessWidget {
  final List<ComplaintModel> complaints;
  final int? propertyId;

  const ComplaintLoggerTab({
    super.key,
    required this.complaints,
    this.propertyId,
  });

  void _showCreateComplaintDialog(BuildContext context) {
    if (propertyId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must have an active booking to log maintenance complaints.')),
      );
      return;
    }

    final titleController = TextEditingController();
    final descController = TextEditingController();
    String category = 'WIFI';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.only(
            top: 24,
            left: 20,
            right: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Raise Maintenance Ticket',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 16),
              const Text('Issue Category', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: category,
                items: const [
                  DropdownMenuItem(value: 'WIFI', child: Text('Wi-Fi / Internet')),
                  DropdownMenuItem(value: 'PLUMBING', child: Text('Plumbing / Water')),
                  DropdownMenuItem(value: 'ELECTRICAL', child: Text('Electrical / AC / Fan')),
                  DropdownMenuItem(value: 'CLEANLINESS', child: Text('Room Cleaning / Housekeeping')),
                  DropdownMenuItem(value: 'FOOD', child: Text('Food Quality / Timing')),
                  DropdownMenuItem(value: 'SECURITY', child: Text('Security / Gate')),
                  DropdownMenuItem(value: 'OTHER', child: Text('Other Issue')),
                ],
                onChanged: (v) {
                  if (v != null) setState(() => category = v);
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: titleController,
                label: 'Issue Title',
                hint: 'e.g. Wi-Fi router not working on 2nd floor',
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: descController,
                label: 'Description',
                hint: 'Describe the problem in detail...',
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              CustomButton(
                text: 'Submit Ticket',
                onPressed: () {
                  if (titleController.text.trim().isNotEmpty && descController.text.trim().isNotEmpty) {
                    context.read<TenantPortalBloc>().add(
                          SubmitComplaintRequested(
                            propertyId: propertyId!,
                            category: category,
                            title: titleController.text.trim(),
                            description: descController.text.trim(),
                          ),
                        );
                    Navigator.of(context).pop();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Action Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          color: Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tickets (${complaints.length})',
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
              ),
              ElevatedButton.icon(
                onPressed: () => _showCreateComplaintDialog(context),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Raise Ticket'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                ),
              ),
            ],
          ),
        ),
        // List
        Expanded(
          child: complaints.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.build_outlined, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        const Text(
                          'No Complaints Raised',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Have an issue with Wi-Fi, electricity, or plumbing? Tap Raise Ticket above.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: complaints.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final complaint = complaints[index];
                    Color statusBg = AppColors.infoBackground;
                    Color statusColor = AppColors.info;

                    if (complaint.isResolved || complaint.isClosed) {
                      statusBg = AppColors.successBackground;
                      statusColor = AppColors.success;
                    } else if (complaint.isInProgress) {
                      statusBg = AppColors.warningBackground;
                      statusColor = AppColors.warning;
                    }

                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.background,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: Text(
                                  complaint.category,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                decoration: BoxDecoration(
                                  color: statusBg,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  complaint.status,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: statusColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            complaint.title,
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            complaint.description,
                            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
