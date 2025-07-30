import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../core/app_export.dart';
import '../../data/services/firebase_auth_service.dart';

class PhoneAuthScreen extends StatefulWidget {
  const PhoneAuthScreen({Key? key}) : super(key: key);

  @override
  State<PhoneAuthScreen> createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends State<PhoneAuthScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();

  bool _isLoading = false;
  bool _codeSent = false;
  String? _verificationId;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _verifyPhone() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseAuthService.instance.verifyPhoneNumber(
        phoneNumber: _phoneController.text,
        onVerificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-verification completed (Android only)
          await _signInWithCredential(credential);
        },
        onVerificationFailed: (FirebaseAuthException e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.message ?? 'Verification failed'),
              backgroundColor: AppTheme.lightTheme.colorScheme.error,
            ),
          );
          setState(() {
            _isLoading = false;
          });
        },
        onCodeSent: (String verificationId) {
          setState(() {
            _verificationId = verificationId;
            _codeSent = true;
            _isLoading = false;
          });
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: AppTheme.lightTheme.colorScheme.error,
        ),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _verifyOTP() async {
    if (_verificationId == null || _otpController.text.length != 6) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: _otpController.text,
      );
      await _signInWithCredential(credential);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Invalid OTP: ${e.toString()}'),
          backgroundColor: AppTheme.lightTheme.colorScheme.error,
        ),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _signInWithCredential(PhoneAuthCredential credential) async {
    try {
      await FirebaseAuthService.instance.signInWithPhoneNumber(
        _verificationId!,
        _otpController.text,
      );

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/college-search-dashboard');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sign in failed: ${e.toString()}'),
            backgroundColor: AppTheme.lightTheme.colorScheme.error,
          ),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 6.w),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildHeader(),
                    SizedBox(height: 6.h),
                    _buildForm(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Hero(
          tag: 'app_logo',
          child: Container(
            width: 25.w,
            height: 25.w,
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.school,
              size: 15.w,
              color: AppTheme.lightTheme.primaryColor,
            ),
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          _codeSent ? "Enter OTP" : "Welcome Back!",
          style: AppTheme.lightTheme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.lightTheme.primaryColor,
          ),
        ),
        SizedBox(height: 1.h),
        Text(
          _codeSent
              ? "Please enter the verification code"
              : "Sign in with your phone number",
          style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          if (!_codeSent) _buildPhoneField(),
          if (_codeSent) ...[
            _buildOTPField(),
            SizedBox(height: 2.h),
            TextButton(
              onPressed: _isLoading ? null : _verifyPhone,
              child: Text(
                "Resend Code",
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.lightTheme.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
          SizedBox(height: 3.h),
          _buildSubmitButton(),
        ],
      ),
    );
  }

  Widget _buildPhoneField() {
    return TextFormField(
      controller: _phoneController,
      keyboardType: TextInputType.phone,
      decoration: InputDecoration(
        labelText: 'Phone Number',
        hintText: '+91 1234567890',
        prefixIcon: CustomIconWidget(
          iconName: 'phone',
          size: 20,
          color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your phone number';
        }
        if (!value.contains('+')) {
          return 'Please include country code (+91)';
        }
        return null;
      },
    );
  }

  Widget _buildOTPField() {
    return TextFormField(
      controller: _otpController,
      keyboardType: TextInputType.number,
      maxLength: 6,
      decoration: InputDecoration(
        labelText: 'Verification Code',
        counterText: '',
        prefixIcon: CustomIconWidget(
          iconName: 'lock',
          size: 20,
          color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter the verification code';
        }
        if (value.length != 6) {
          return 'Please enter a valid 6-digit code';
        }
        return null;
      },
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 6.h,
      child: ElevatedButton(
        onPressed: _isLoading
            ? null
            : _codeSent
                ? _verifyOTP
                : _verifyPhone,
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isLoading
            ? SizedBox(
                height: 3.h,
                width: 3.h,
                child: CircularProgressIndicator(
                  color: AppTheme.lightTheme.colorScheme.onPrimary,
                  strokeWidth: 2,
                ),
              )
            : Text(
                _codeSent ? 'Verify' : 'Send Code',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
} 