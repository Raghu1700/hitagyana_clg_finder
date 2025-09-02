import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../../core/app_export.dart';
import '../../services/auth_service.dart';

class PaymentPortal extends StatefulWidget {
  final Map<String, dynamic> course;
  final Function(String) onPaymentSuccess;

  const PaymentPortal({
    Key? key,
    required this.course,
    required this.onPaymentSuccess,
  }) : super(key: key);

  @override
  State<PaymentPortal> createState() => _PaymentPortalState();
}

class _PaymentPortalState extends State<PaymentPortal> {
  late Razorpay _razorpay;
  bool _isLoading = false;
  String _selectedPaymentMethod = 'card';

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    print('Payment Success: ${response.paymentId}');
    widget.onPaymentSuccess(response.paymentId!);
    Navigator.pop(context);
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    print('Payment Error: ${response.code} - ${response.message}');
    setState(() => _isLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Payment failed: ${response.message}'),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    print('External Wallet: ${response.walletName}');
  }

  void _processPayment() {
    setState(() => _isLoading = true);

    final options = {
      'key': 'rzp_test_1DP5mmOlF5G5ag', // Replace with your Razorpay key
      'amount': (widget.course['price'] * 100).toInt(), // Amount in paise
      'name': 'Hitagyana College Finder',
      'description': 'Course Enrollment: ${widget.course['name']}',
      'prefill': {
        'contact': '9876543210',
        'email': AuthService.currentUser?.email ?? 'user@example.com'
      },
      'external': {
        'wallets': ['paytm']
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      setState(() => _isLoading = false);
      print('Error opening payment: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error processing payment: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.almond,
      appBar: AppBar(
        backgroundColor: AppTheme.pureWhite,
        elevation: 0,
        title: Text(
          'Payment',
          style: TextStyle(
            color: AppTheme.tyrianPurple,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppTheme.byzantium),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(4.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Course Summary
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: AppTheme.pureWhite,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: AppTheme.softShadow,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Course Summary',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.tyrianPurple,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Row(
                      children: [
                        Container(
                          width: 15.w,
                          height: 15.w,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            image: DecorationImage(
                              image: NetworkImage(widget.course['image'] ??
                                  'https://images.unsplash.com/photo-1522202176988-66273c2fd55f?w=800&h=600&fit=crop'),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        SizedBox(width: 3.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.course['name'] ?? 'Course Name',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.tyrianPurple,
                                ),
                              ),
                              SizedBox(height: 0.5.h),
                              Text(
                                'Instructor: ${widget.course['instructor'] ?? 'Dr. John Doe'}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.byzantium,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: 3.h),

              // Payment Methods
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: AppTheme.pureWhite,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: AppTheme.softShadow,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Payment Method',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.tyrianPurple,
                      ),
                    ),
                    SizedBox(height: 2.h),

                    // Credit/Debit Card
                    _buildPaymentMethod(
                      'card',
                      'Credit/Debit Card',
                      Icons.credit_card,
                      'Pay with your credit or debit card',
                    ),

                    SizedBox(height: 2.h),

                    // UPI
                    _buildPaymentMethod(
                      'upi',
                      'UPI',
                      Icons.account_balance_wallet,
                      'Pay using UPI apps like Google Pay, PhonePe',
                    ),

                    SizedBox(height: 2.h),

                    // Net Banking
                    _buildPaymentMethod(
                      'netbanking',
                      'Net Banking',
                      Icons.account_balance,
                      'Pay using your bank account',
                    ),
                  ],
                ),
              ),

              SizedBox(height: 3.h),

              // Price Breakdown
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: AppTheme.pureWhite,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: AppTheme.softShadow,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Price Breakdown',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.tyrianPurple,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Course Price',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppTheme.byzantium,
                          ),
                        ),
                        Text(
                          '₹${widget.course['price'] ?? 2999}',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppTheme.byzantium,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 1.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'GST (18%)',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppTheme.byzantium,
                          ),
                        ),
                        Text(
                          '₹${((widget.course['price'] ?? 2999) * 0.18).toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppTheme.byzantium,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 1.h),
                    Divider(color: AppTheme.byzantium),
                    SizedBox(height: 1.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total Amount',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.tyrianPurple,
                          ),
                        ),
                        Text(
                          '₹${((widget.course['price'] ?? 2999) * 1.18).toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.tyrianPurple,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: 3.h),

              // Pay Now Button
              Container(
                width: double.infinity,
                height: 6.h,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _processPayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.tyrianPurple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text(
                          'Pay ₹${((widget.course['price'] ?? 2999) * 1.18).toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),

              SizedBox(height: 2.h),

              // Security Notice
              Container(
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.security, color: Colors.green, size: 20),
                    SizedBox(width: 2.w),
                    Expanded(
                      child: Text(
                        'Your payment is secure and encrypted. We use industry-standard security measures.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.green[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentMethod(
      String value, String title, IconData icon, String subtitle) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPaymentMethod = value;
        });
      },
      child: Container(
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          color: _selectedPaymentMethod == value
              ? AppTheme.tyrianPurple.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _selectedPaymentMethod == value
                ? AppTheme.tyrianPurple
                : Colors.grey.withOpacity(0.3),
            width: _selectedPaymentMethod == value ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: _selectedPaymentMethod == value
                  ? AppTheme.tyrianPurple
                  : AppTheme.byzantium,
              size: 24,
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: _selectedPaymentMethod == value
                          ? AppTheme.tyrianPurple
                          : AppTheme.byzantium,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.byzantium,
                    ),
                  ),
                ],
              ),
            ),
            Radio<String>(
              value: value,
              groupValue: _selectedPaymentMethod,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedPaymentMethod = newValue!;
                });
              },
              activeColor: AppTheme.tyrianPurple,
            ),
          ],
        ),
      ),
    );
  }
}
