import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../bloc/tenant_portal_bloc.dart';
import '../bloc/tenant_portal_event.dart';
import '../models/invoice_model.dart';

class InvoiceListTab extends StatelessWidget {
  final List<InvoiceModel> invoices;

  const InvoiceListTab({super.key, required this.invoices});

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

    if (invoices.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              const Text(
                'No Rent Invoices',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              const Text(
                'Monthly invoices will automatically appear here on the 1st of every month.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: invoices.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final invoice = invoices[index];
        Color statusBg = AppColors.warningBackground;
        Color statusColor = AppColors.warning;

        if (invoice.isPaid) {
          statusBg = AppColors.successBackground;
          statusColor = AppColors.success;
        } else if (invoice.isOverdue) {
          statusBg = AppColors.errorBackground;
          statusColor = AppColors.error;
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
                  Text(
                    invoice.invoiceNumber,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusBg,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      invoice.status,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Billing Month: ${invoice.billingMonth} • Due Date: ${invoice.dueDate}',
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              const Divider(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Total Payable',
                        style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                      ),
                      Text(
                        currencyFormatter.format(invoice.totalAmount),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  if (!invoice.isPaid)
                    ElevatedButton(
                      onPressed: () {
                        context.read<TenantPortalBloc>().add(PayInvoiceRequested(invoice.id));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                      ),
                      child: const Text('Pay Now', style: TextStyle(fontWeight: FontWeight.w700)),
                    )
                  else
                    const Row(
                      children: [
                        Icon(Icons.check_circle, size: 16, color: AppColors.success),
                        SizedBox(width: 4),
                        Text(
                          'Settled',
                          style: TextStyle(color: AppColors.success, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
