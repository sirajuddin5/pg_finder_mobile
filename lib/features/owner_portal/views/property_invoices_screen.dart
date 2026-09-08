import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_shimmer.dart';
import '../bloc/owner_bloc.dart';
import '../bloc/owner_event.dart';
import '../bloc/owner_state.dart';

class PropertyInvoicesScreen extends StatefulWidget {
  final int propertyId;
  final String propertyTitle;

  const PropertyInvoicesScreen({
    super.key,
    required this.propertyId,
    required this.propertyTitle,
  });

  @override
  State<PropertyInvoicesScreen> createState() => _PropertyInvoicesScreenState();
}

class _PropertyInvoicesScreenState extends State<PropertyInvoicesScreen> {
  @override
  void initState() {
    super.initState();
    context
        .read<OwnerBloc>()
        .add(LoadPropertyInvoicesRequested(propertyId: widget.propertyId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('${AppStrings.propertyInvoices} • ${widget.propertyTitle}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => context
                .read<OwnerBloc>()
                .add(LoadPropertyInvoicesRequested(propertyId: widget.propertyId)),
          ),
        ],
      ),
      body: BlocBuilder<OwnerBloc, OwnerState>(
        builder: (context, state) {
          if (state is OwnerLoading && state is! PropertyInvoicesLoaded) {
            return const Padding(
              padding: EdgeInsets.all(16.0),
              child: LoadingShimmer(width: double.infinity, height: 350),
            );
          } else if (state is OwnerError) {
            return ErrorView(
              message: state.message,
              onRetry: () => context
                  .read<OwnerBloc>()
                  .add(LoadPropertyInvoicesRequested(propertyId: widget.propertyId)),
            );
          } else if (state is PropertyInvoicesLoaded) {
            final invoices = state.invoices;

            final totalBilled = invoices.fold<double>(0.0, (sum, inv) => sum + inv.totalAmount);
            final totalCollected = invoices
                .where((inv) => inv.isPaid)
                .fold<double>(0.0, (sum, inv) => sum + inv.totalAmount);
            final totalPending = totalBilled - totalCollected;

            return ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                // Revenue Summary Cards
                Row(
                  children: [
                    Expanded(
                      child: _buildSummaryCard(
                        'Total Billed',
                        '₹${totalBilled.toInt()}',
                        AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildSummaryCard(
                        'Collected',
                        '₹${totalCollected.toInt()}',
                        AppColors.success,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildSummaryCard(
                        'Pending',
                        '₹${totalPending.toInt()}',
                        totalPending > 0 ? AppColors.warning : AppColors.success,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                const Text(
                  'Tenant Rent Invoices',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),

                if (invoices.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40.0),
                      child: Column(
                        children: [
                          Icon(Icons.receipt_long_outlined,
                              size: 56,
                              color: AppColors.textMuted.withAlpha(150)),
                          const SizedBox(height: 12),
                          const Text(
                            'No Invoices Generated Yet',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ...invoices.map((inv) {
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
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              inv.invoiceNumber,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              '₹${inv.totalAmount.toInt()}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              'Billing Month: ${inv.billingMonth} • Due: ${inv.dueDate}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textMuted,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: (inv.isPaid
                                        ? AppColors.success
                                        : AppColors.warning)
                                    .withAlpha(25),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                inv.status,
                                style: TextStyle(
                                  color: inv.isPaid
                                      ? AppColors.success
                                      : AppColors.warning,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
