import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class KycUploadScreen extends StatefulWidget {
  const KycUploadScreen({super.key});

  @override
  State<KycUploadScreen> createState() => _KycUploadScreenState();
}

class _KycUploadScreenState extends State<KycUploadScreen> {
  final _formKey = GlobalKey<FormState>();
  final _docNumberController = TextEditingController();
  String _selectedDocType = 'AADHAAR';
  final String _mockDocUrl = 'https://s3.amazonaws.com/pgfinder/kyc/sample_aadhaar.jpg';

  @override
  void dispose() {
    _docNumberController.dispose();
    super.dispose();
  }

  void _onUploadPressed() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
            KycUploaded(
              documentType: _selectedDocType,
              documentNumber: _docNumberController.text.trim(),
              documentUrl: _mockDocUrl,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Identity Verification (KYC)'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is Authenticated) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('KYC Document submitted for verification!'),
                  backgroundColor: AppColors.success,
                  behavior: SnackBarBehavior.floating,
                ),
              );
              context.pop();
            } else if (state is AuthError) {
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
            final isLoading = state is AuthLoading;

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Verify Your Government ID',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'To maintain safety and compliance across all PGs, please submit your identification.',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 28),
                    const Text(
                      'Document Type',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF334155),
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedDocType,
                      items: const [
                        DropdownMenuItem(value: 'AADHAAR', child: Text('Aadhaar Card')),
                        DropdownMenuItem(value: 'PASSPORT', child: Text('Passport')),
                        DropdownMenuItem(value: 'DRIVING_LICENSE', child: Text('Driving License')),
                        DropdownMenuItem(value: 'VOTER_ID', child: Text('Voter ID')),
                      ],
                      onChanged: (v) {
                        if (v != null) setState(() => _selectedDocType = v);
                      },
                      decoration: const InputDecoration(),
                    ),
                    const SizedBox(height: 20),
                    CustomTextField(
                      controller: _docNumberController,
                      label: 'Document Number',
                      hint: 'e.g. 1234 5678 9012',
                      prefixIcon: Icons.badge_outlined,
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter document number' : null,
                    ),
                    const SizedBox(height: 24),
                    // Upload Box Preview
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border, style: BorderStyle.solid),
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.cloud_upload_outlined,
                              size: 32,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Document Photo Attached',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'sample_aadhaar.jpg (Secure S3 Presigned)',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    CustomButton(
                      text: 'Submit KYC Document',
                      onPressed: _onUploadPressed,
                      isLoading: isLoading,
                      icon: Icons.verified_user_outlined,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
