import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../../core/app_export.dart';
import '../../services/auth_service.dart';
import '../../services/firebase_service.dart';

class CoursePage extends StatefulWidget {
  final Map<String, dynamic> course;

  const CoursePage({Key? key, required this.course}) : super(key: key);

  @override
  State<CoursePage> createState() => _CoursePageState();
}

class _CoursePageState extends State<CoursePage> {
  bool _isEnrolled = false;
  bool _isLoading = false;
  late Razorpay _razorpay;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    _checkEnrollmentStatus();
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  Future<void> _checkEnrollmentStatus() async {
    try {
      final user = AuthService.currentUser;
      if (user != null) {
        final enrolledCourses =
            await FirebaseService.getEnrolledCourses(user.uid);
        setState(() {
          _isEnrolled = enrolledCourses
              .any((course) => course['id'] == widget.course['id']);
        });
      }
    } catch (e) {
      print('Error checking enrollment status: $e');
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    print('Payment Success: ${response.paymentId}');
    _enrollInCourse(response.paymentId!);
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    print('Payment Error: ${response.code} - ${response.message}');
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

  Future<void> _enrollInCourse(String paymentId) async {
    setState(() => _isLoading = true);

    try {
      final user = AuthService.currentUser;
      if (user != null) {
        await FirebaseService.enrollInCourse(
          user.uid,
          widget.course['id'],
          paymentId,
        );

        setState(() {
          _isEnrolled = true;
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Successfully enrolled in ${widget.course['name']}!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Enrollment failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _startPayment() {
    final options = {
      'key': 'rzp_test_1DP5mmOlF5G5ag', // Replace with your Razorpay key
      'amount': (widget.course['price'] * 100).toInt(), // Amount in paise
      'name': 'Hitagyana College Finder',
      'description': 'Course Enrollment: ${widget.course['name']}',
      'prefill': {
        'contact': '9876543210',
        'email': AuthService.currentUser?.email ?? 'user@example.com'
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      print('Error opening payment: $e');
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
          widget.course['name'] ?? 'Course',
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
              // Course Header Card
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
                    // Course Image
                    Container(
                      height: 20.h,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        image: DecorationImage(
                          image: NetworkImage(widget.course['image'] ??
                              'https://images.unsplash.com/photo-1522202176988-66273c2fd55f?w=800&h=600&fit=crop'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    SizedBox(height: 3.h),

                    // Course Title
                    Text(
                      widget.course['name'] ?? 'Course Name',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.tyrianPurple,
                      ),
                    ),
                    SizedBox(height: 1.h),

                    // Instructor
                    Row(
                      children: [
                        Icon(Icons.person, color: AppTheme.byzantium, size: 16),
                        SizedBox(width: 1.w),
                        Text(
                          'Instructor: ${widget.course['instructor'] ?? 'Dr. John Doe'}',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppTheme.byzantium,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 1.h),

                    // Rating
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 16),
                        SizedBox(width: 1.w),
                        Text(
                          '${widget.course['rating'] ?? 4.5} (${widget.course['reviewCount'] ?? 120} reviews)',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppTheme.byzantium,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 1.h),

                    // Price
                    Row(
                      children: [
                        Text(
                          '₹${widget.course['price'] ?? 2999}',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.tyrianPurple,
                          ),
                        ),
                        SizedBox(width: 2.w),
                        if (widget.course['originalPrice'] != null)
                          Text(
                            '₹${widget.course['originalPrice']}',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: 3.h),

              // Course Details
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
                      'About This Course',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.tyrianPurple,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      widget.course['description'] ??
                          'This is a comprehensive course designed to help you master the subject. You will learn from industry experts and get hands-on experience with real-world projects.',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.byzantium,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 3.h),

              // Course Features
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
                      'What You\'ll Learn',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.tyrianPurple,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    ...(widget.course['features'] ??
                            [
                              'Complete course materials',
                              'Lifetime access',
                              'Certificate of completion',
                              '24/7 support',
                              'Mobile and desktop access'
                            ])
                        .map((feature) => Padding(
                              padding: EdgeInsets.only(bottom: 1.h),
                              child: Row(
                                children: [
                                  Icon(Icons.check_circle,
                                      color: Colors.green, size: 16),
                                  SizedBox(width: 2.w),
                                  Expanded(
                                    child: Text(
                                      feature,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: AppTheme.byzantium,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ))
                        .toList(),
                  ],
                ),
              ),

              SizedBox(height: 3.h),

              // Enrollment Button
              if (!_isEnrolled)
                Container(
                  width: double.infinity,
                  height: 6.h,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _startPayment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.tyrianPurple,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text(
                            'Enroll Now - ₹${widget.course['price'] ?? 2999}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                )
              else
                Container(
                  width: double.infinity,
                  height: 6.h,
                  child: ElevatedButton(
                    onPressed: () {
                      // Navigate to course content
                      Navigator.pushNamed(
                        context,
                        '/course-content',
                        arguments: widget.course,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Access Course',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

              SizedBox(height: 2.h),
            ],
          ),
        ),
      ),
    );
  }
}
