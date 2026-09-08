import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/custom_button.dart';
import '../../property/models/bed_model.dart';
import '../../property/models/property_detail_model.dart';
import '../../property/models/room_model.dart';
import '../bloc/booking_bloc.dart';
import '../bloc/booking_event.dart';
import '../bloc/booking_state.dart';
import 'booking_success_dialog.dart';

class BookingCheckoutSheet extends StatefulWidget {
  final PropertyDetailModel property;
  final RoomModel room;
  final BedModel bed;

  const BookingCheckoutSheet({
    super.key,
    required this.property,
    required this.room,
    required this.bed,
  });

  @override
  State<BookingCheckoutSheet> createState() => _BookingCheckoutSheetState();
}

class _BookingCheckoutSheetState extends State<BookingCheckoutSheet> {
  DateTime _checkInDate = DateTime.now().add(const Duration(days: 2));
  final double _tokenAdvanceAmount = 2000.00;
  Timer? _countdownTimer;
  int _secondsRemaining = 900; // 15 minutes

  @override
  void initState() {
    super.initState();
    context.read<BookingBloc>().add(ResetBookingFlow());
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _startTimer(DateTime expiresAt) {
    _countdownTimer?.cancel();
    final difference = expiresAt.difference(DateTime.now()).inSeconds;
    _secondsRemaining = difference > 0 ? difference : 0;

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        timer.cancel();
      }
    });
  }

  String _formatTimer(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  void _onReservePressed() {
    final checkInStr = DateFormat('yyyy-MM-dd').format(_checkInDate);
    context.read<BookingBloc>().add(
          InitiateBookingRequested(
            bedId: widget.bed.id,
            checkInDate: checkInStr,
            tokenAmount: _tokenAdvanceAmount,
          ),
        );
  }

  void _onSimulatePayment(int bookingId, String orderId) {
    // In production this triggers Razorpay SDK; for test & client we generate valid mock payment params
    final paymentId = 'pay_mobile_${DateTime.now().millisecondsSinceEpoch}';
    final mockSignature = 'sig_mock_${orderId}_$paymentId';

    context.read<BookingBloc>().add(
          ConfirmPaymentRequested(
            bookingId: bookingId,
            orderId: orderId,
            paymentId: paymentId,
            signature: mockSignature,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
    final dateFormatter = DateFormat('EEE, dd MMM yyyy');

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Checkout & Reservation'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: BlocConsumer<BookingBloc, BookingState>(
        listener: (context, state) {
          if (state is BedReservedPendingPayment) {
            _startTimer(state.expiresAt);
          } else if (state is BookingConfirmedSuccess) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (_) => BookingSuccessDialog(booking: state.booking),
            );
          } else if (state is BookingError) {
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
          final isReserved = state is BedReservedPendingPayment;
          final isVerifying = state is PaymentVerifying;
          final isInitiating = state is BookingInitiating;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 15-Minute Countdown Timer Banner (When reserved)
                if (isReserved) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.warningBackground,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.warning.withValues(alpha: 0.5)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.timer_outlined, color: AppColors.warning, size: 28),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Bed Temporarily Locked',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                  color: Color(0xFF92400E),
                                ),
                              ),
                              Text(
                                'Complete advance payment in ${_formatTimer(_secondsRemaining)} to confirm.',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFFB45309),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.warning,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _formatTimer(_secondsRemaining),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // Property Summary Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.property.title,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${widget.property.addressLine}, ${widget.property.city}',
                        style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                      ),
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildDetailCol('Room', widget.room.roomNumber),
                          _buildDetailCol('Bed', widget.bed.bedIdentifier),
                          _buildDetailCol('Sharing', widget.room.sharingType),
                          _buildDetailCol('Floor', '${widget.room.floorNumber}'),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Check-in Date Selector
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Planned Check-in Date',
                            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            dateFormatter.format(_checkInDate),
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                      if (!isReserved)
                        OutlinedButton(
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: _checkInDate,
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now().add(const Duration(days: 60)),
                            );
                            if (picked != null) setState(() => _checkInDate = picked);
                          },
                          child: const Text('Change'),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Price Breakdown
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Payment Breakdown',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 16),
                      _buildPriceRow('Monthly Rent', currencyFormatter.format(widget.room.baseRentMonthly)),
                      const SizedBox(height: 10),
                      _buildPriceRow('Security Deposit (Refundable)', currencyFormatter.format(widget.room.securityDeposit)),
                      const SizedBox(height: 10),
                      _buildPriceRow('Token Advance Payable Today', currencyFormatter.format(_tokenAdvanceAmount), isBold: true),
                      const Divider(height: 24),
                      Text(
                        'Remaining rent & security deposit balance will be billed on check-in.',
                        style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Action Buttons
                if (!isReserved)
                  CustomButton(
                    text: 'Reserve Bed (Lock for 15 mins)',
                    onPressed: _onReservePressed,
                    isLoading: isInitiating,
                    icon: Icons.lock_clock_rounded,
                  )
                else
                  CustomButton(
                    text: 'Pay ${currencyFormatter.format(_tokenAdvanceAmount)} Advance Token',
                    onPressed: () {
                      final orderId = state.booking.paymentOrder?.orderId ?? 'order_mock_${state.booking.id}';
                      _onSimulatePayment(state.booking.id, orderId);
                    },
                    isLoading: isVerifying,
                    icon: Icons.payment_rounded,
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailCol(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
      ],
    );
  }

  Widget _buildPriceRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isBold ? 14 : 13,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.normal,
            color: isBold ? AppColors.textPrimary : AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? 15 : 13,
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
            color: isBold ? AppColors.primary : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
