import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_shimmer.dart';
import '../bloc/admin_bloc.dart';
import '../bloc/admin_event.dart';
import '../bloc/admin_state.dart';
import '../models/kyc_document_model.dart';

class AdminKycVerificationScreen extends StatefulWidget {
  const AdminKycVerificationScreen({super.key});

  @override
  State<AdminKycVerificationScreen> createState() =>
      _AdminKycVerificationScreenState();
}

class _AdminKycVerificationScreenState
    extends State<AdminKycVerificationScreen> {
  String _selectedFilter = 'ALL';

  @override
  void initState() {
    super.initState();
    context.read<AdminBloc>().add(FetchPendingKycRequested());
  }

  void _showDocumentPreview(BuildContext context, KycDocumentModel doc) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${doc.documentType} Document',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                height: 220,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.divider),
                ),
                child: doc.documentUrl.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          doc.documentUrl,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => const Center(
                            child: Icon(Icons.description_rounded, size: 64, color: AppColors.primary),
                          ),
                        ),
                      )
                    : const Center(
                        child: Icon(Icons.description_rounded, size: 64, color: AppColors.primary),
                      ),
              ),
              const SizedBox(height: 12),
              Text('ID Number: ${doc.documentNumber}', style: const TextStyle(fontWeight: FontWeight.w600)),
              Text('Submitted by: ${doc.userName} (${doc.userRole})', style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }

  void _showRejectionDialog(BuildContext context, KycDocumentModel doc) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reject KYC Document'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Reject ${doc.documentType} submitted by ${doc.userName}?'),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                hintText: 'e.g., Document image is illegible / expired',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              final reason = reasonController.text.trim();
              if (reason.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter rejection reason')),
                );
                return;
              }
              Navigator.pop(ctx);
              context.read<AdminBloc>().add(
                    VerifyKycSubmitted(
                      documentId: doc.id,
                      status: 'REJECTED',
                      rejectionReason: reason,
                    ),
                  );
            },
            child: const Text('Reject KYC', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.kycVerification),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () =>
                context.read<AdminBloc>().add(FetchPendingKycRequested()),
          ),
        ],
      ),
      body: BlocConsumer<AdminBloc, AdminState>(
        listener: (context, state) {
          if (state is KycVerifiedSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.success,
                behavior: SnackBarBehavior.floating,
              ),
            );
          } else if (state is AdminError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is AdminLoading && state is! PendingKycLoaded) {
            return const Padding(
              padding: EdgeInsets.all(16.0),
              child: LoadingShimmer(width: double.infinity, height: 350),
            );
          } else if (state is AdminError) {
            return ErrorView(
              message: state.message,
              onRetry: () =>
                  context.read<AdminBloc>().add(FetchPendingKycRequested()),
            );
          } else if (state is PendingKycLoaded) {
            var docs = state.documents;

            if (_selectedFilter != 'ALL') {
              docs = docs.where((d) => d.status == _selectedFilter).toList();
            }

            return Column(
              children: [
                // Filter Tabs
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      _buildFilterChip('ALL', 'All'),
                      const SizedBox(width: 8),
                      _buildFilterChip('PENDING', 'Pending'),
                      const SizedBox(width: 8),
                      _buildFilterChip('VERIFIED', 'Verified'),
                      const SizedBox(width: 8),
                      _buildFilterChip('REJECTED', 'Rejected'),
                    ],
                  ),
                ),
                Expanded(
                  child: docs.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.badge_outlined,
                                  size: 64, color: AppColors.textMuted.withAlpha(150)),
                              const SizedBox(height: 16),
                              const Text(
                                'No KYC Documents Found',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16.0),
                          itemCount: docs.length,
                          itemBuilder: (context, index) {
                            final doc = docs[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withAlpha(6),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(14.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          doc.userName,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                        _buildStatusBadge(doc.status),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${doc.documentType} • ${doc.documentNumber}',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    Text(
                                      'Role: ${doc.userRole} | ${doc.userEmail}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textMuted,
                                      ),
                                    ),
                                    const Divider(height: 20),
                                    Row(
                                      children: [
                                        TextButton.icon(
                                          icon: const Icon(Icons.visibility_outlined, size: 16),
                                          label: const Text('View Proof'),
                                          onPressed: () => _showDocumentPreview(context, doc),
                                        ),
                                        const Spacer(),
                                        if (doc.isPending) ...[
                                          OutlinedButton(
                                            style: OutlinedButton.styleFrom(
                                              foregroundColor: AppColors.error,
                                              side: const BorderSide(color: AppColors.error),
                                            ),
                                            onPressed: () => _showRejectionDialog(context, doc),
                                            child: const Text('Reject'),
                                          ),
                                          const SizedBox(width: 8),
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: AppColors.success,
                                              foregroundColor: Colors.white,
                                            ),
                                            onPressed: () {
                                              context.read<AdminBloc>().add(
                                                    VerifyKycSubmitted(
                                                      documentId: doc.id,
                                                      status: 'VERIFIED',
                                                    ),
                                                  );
                                            },
                                            child: const Text('Approve'),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildFilterChip(String value, String label) {
    final isSelected = _selectedFilter == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) setState(() => _selectedFilter = value);
      },
      selectedColor: AppColors.primary.withAlpha(30),
      labelStyle: TextStyle(
        color: isSelected ? AppColors.primary : AppColors.textSecondary,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 12,
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bg = AppColors.warning.withAlpha(25);
    Color fg = AppColors.warning;

    if (status == 'VERIFIED') {
      bg = AppColors.success.withAlpha(25);
      fg = AppColors.success;
    } else if (status == 'REJECTED') {
      bg = AppColors.error.withAlpha(25);
      fg = AppColors.error;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status,
        style: TextStyle(color: fg, fontWeight: FontWeight.bold, fontSize: 11),
      ),
    );
  }
}
