import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoAnimationController;
  late AnimationController _loadingAnimationController;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoFadeAnimation;
  late Animation<double> _loadingAnimation;

  bool _isLoading = true;
  String _loadingText = "Initializing...";
  bool _showRetry = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startSplashSequence();
  }

  void _initializeAnimations() {
    _logoAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _loadingAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat(reverse: true);

    _logoScaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoAnimationController,
      curve: Curves.elasticOut,
    ));

    _logoFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoAnimationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
    ));

    _loadingAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _loadingAnimationController,
      curve: Curves.easeInOut,
    ));

    _logoAnimationController.forward();
  }

  Future<void> _startSplashSequence() async {
    try {
      // Simulate initialization tasks
      await _performInitializationTasks();

      if (mounted) {
        _navigateToNextScreen();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _showRetry = true;
          _loadingText = "Connection failed. Tap to retry.";
        });
      }
    }
  }

  Future<void> _performInitializationTasks() async {
    // Simulate checking authentication status
    setState(() {
      _loadingText = "Checking authentication...";
    });
    await Future.delayed(const Duration(milliseconds: 800));

    // Simulate loading cached college data
    setState(() {
      _loadingText = "Loading college data...";
    });
    await Future.delayed(const Duration(milliseconds: 700));

    // Simulate fetching app configuration
    setState(() {
      _loadingText = "Fetching configuration...";
    });
    await Future.delayed(const Duration(milliseconds: 600));

    // Simulate preparing video streaming capabilities
    setState(() {
      _loadingText = "Preparing video services...";
    });
    await Future.delayed(const Duration(milliseconds: 500));

    setState(() {
      _loadingText = "Ready to launch!";
    });
    await Future.delayed(const Duration(milliseconds: 400));
  }

  void _navigateToNextScreen() {
    // Simulate navigation logic based on user state
    final bool isAuthenticated = false; // Mock authentication check
    final bool isFirstTime = true; // Mock first-time user check

    String nextRoute;
    if (isAuthenticated) {
      nextRoute = '/college-search-dashboard';
    } else if (isFirstTime) {
      nextRoute = '/onboarding-flow';
    } else {
      nextRoute = '/college-search-dashboard'; // Default to dashboard for demo
    }

    Navigator.pushReplacementNamed(context, nextRoute);
  }

  void _testFirebaseIntegration() {
    Navigator.pushNamed(context, '/firebase-test-screen');
  }

  @override
  void dispose() {
    _logoAnimationController.dispose();
    _loadingAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.colorScheme.background,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo Section
              ScaleTransition(
                scale: _logoScaleAnimation,
                child: FadeTransition(
                  opacity: _logoFadeAnimation,
                  child: Container(
                    width: 40.w,
                    height: 40.w,
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.lightTheme.colorScheme.shadow
                              .withValues(alpha: 0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: CustomImageWidget(
                        imageUrl: "assets/images/img_app_logo.svg",
                        height: 25.w,
                        width: 25.w,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 4.h),

              // App Name
              FadeTransition(
                opacity: _logoFadeAnimation,
                child: Text(
                  "Hitagyana College Finder",
                  style: AppTheme.lightTheme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.lightTheme.colorScheme.onBackground,
                  ),
                ),
              ),
              SizedBox(height: 1.h),

              // Tagline
              FadeTransition(
                opacity: _logoFadeAnimation,
                child: Text(
                  "Find your perfect college match",
                  style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onBackground
                        .withValues(alpha: 0.7),
                  ),
                ),
              ),
              SizedBox(height: 8.h),

              // Loading Indicator
              if (_isLoading) ...[
                FadeTransition(
                  opacity: _loadingAnimation,
                  child: CircularProgressIndicator(
                    color: AppTheme.lightTheme.colorScheme.primary,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  _loadingText,
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onBackground
                        .withValues(alpha: 0.6),
                  ),
                ),
              ],

              // Retry Button
              if (_showRetry)
                ElevatedButton(
                  onPressed: _startSplashSequence,
                  child: const Text("Retry"),
                ),

              // Firebase Test Button
              SizedBox(height: 20.h),
              TextButton.icon(
                onPressed: _testFirebaseIntegration,
                icon: Icon(Icons.verified_outlined,
                    color: AppTheme.lightTheme.colorScheme.primary),
                label: Text(
                  "Test Firebase Integration",
                  style: TextStyle(
                    color: AppTheme.lightTheme.colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
