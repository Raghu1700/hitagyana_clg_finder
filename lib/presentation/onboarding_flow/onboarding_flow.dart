import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';

class OnboardingFlow extends StatefulWidget {
  const OnboardingFlow({Key? key}) : super(key: key);

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  int _currentPage = 0;

  final List<Map<String, dynamic>> _onboardingData = [
    {
      "id": 1,
      "title": "Discover Your Perfect College",
      "description":
          "Search and filter colleges by name, city, state, rank, and website. Find the institution that matches your academic goals and preferences.",
      "image":
          "https://images.unsplash.com/photo-1523050854058-8df90110c9f1?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3",
      "color": Color(0xFF1E3A8A),
    },
    {
      "id": 2,
      "title": "Transparent Fee Information",
      "description":
          "Get detailed breakdown of tuition fees, college fees, and hostel costs. Make informed financial decisions for your education.",
      "image":
          "https://images.unsplash.com/photo-1554224155-6726b3ff858f?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3",
      "color": Color(0xFFF59E0B),
    },
    {
      "id": 3,
      "title": "Learn Beyond Academics",
      "description":
          "Join online extracurricular classes, attend live sessions, and develop skills that complement your academic journey.",
      "image":
          "https://images.unsplash.com/photo-1522202176988-66273c2fd55f?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3",
      "color": Color(0xFF8B5CF6),
    },
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });

    // Haptic feedback for iOS-like experience
    HapticFeedback.lightImpact();

    // Restart animation for new page
    _animationController.reset();
    _animationController.forward();
  }

  void _nextPage() {
    if (_currentPage < _onboardingData.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _navigateToCollegeSearch();
    }
  }

  void _skipOnboarding() {
    _navigateToCollegeSearch();
  }

  void _navigateToCollegeSearch() {
    Navigator.pushReplacementNamed(context, '/college-search-dashboard');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(
              child: _buildPageView(),
            ),
            _buildBottomSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo/Brand
          Text(
            "Hitagyana",
            style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppTheme.lightTheme.primaryColor,
            ),
          ),
          // Skip button
          TextButton(
            onPressed: _skipOnboarding,
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
            ),
            child: Text(
              "Skip",
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageView() {
    return PageView.builder(
      controller: _pageController,
      onPageChanged: _onPageChanged,
      itemCount: _onboardingData.length,
      itemBuilder: (context, index) {
        final data = _onboardingData[index];
        return FadeTransition(
          opacity: _fadeAnimation,
          child: _buildOnboardingPage(data),
        );
      },
    );
  }

  Widget _buildOnboardingPage(Map<String, dynamic> data) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Hero illustration
            Container(
              width: 80.w,
              height: 35.h,
              margin: EdgeInsets.only(bottom: 4.h),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: (data["color"] as Color).withValues(alpha: 0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: CustomImageWidget(
                  imageUrl: data["image"] as String,
                  width: 80.w,
                  height: 35.h,
                  fit: BoxFit.cover,
                ),
              ),
            ),

            // Headline
            Container(
              margin: EdgeInsets.only(bottom: 2.h),
              child: Text(
                data["title"] as String,
                textAlign: TextAlign.center,
                style: AppTheme.lightTheme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: data["color"] as Color,
                  height: 1.2,
                ),
              ),
            ),

            // Description
            Container(
              margin: EdgeInsets.only(bottom: 4.h),
              child: Text(
                data["description"] as String,
                textAlign: TextAlign.center,
                style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSection() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
      child: Column(
        children: [
          // Page indicators
          _buildPageIndicators(),
          SizedBox(height: 3.h),

          // CTA Button
          _buildCTAButton(),

          // Permission preview for final slide
          _currentPage == _onboardingData.length - 1
              ? _buildPermissionPreview()
              : const SizedBox.shrink(),
        ],
      ),
    );
  }

  Widget _buildPageIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _onboardingData.length,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: EdgeInsets.symmetric(horizontal: 1.w),
          width: _currentPage == index ? 8.w : 2.w,
          height: 1.h,
          decoration: BoxDecoration(
            color: _currentPage == index
                ? AppTheme.lightTheme.primaryColor
                : AppTheme.lightTheme.colorScheme.outline
                    .withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  Widget _buildCTAButton() {
    final isLastPage = _currentPage == _onboardingData.length - 1;

    return Container(
      width: double.infinity,
      height: 6.h,
      child: ElevatedButton(
        onPressed: _nextPage,
        style: ElevatedButton.styleFrom(
          backgroundColor: _onboardingData[_currentPage]["color"] as Color,
          foregroundColor: Colors.white,
          elevation: 4,
          shadowColor: (_onboardingData[_currentPage]["color"] as Color)
              .withValues(alpha: 0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              isLastPage ? "Get Started" : "Next",
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(width: 2.w),
            CustomIconWidget(
              iconName: isLastPage ? 'rocket_launch' : 'arrow_forward',
              color: Colors.white,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionPreview() {
    return Container(
      margin: EdgeInsets.only(top: 3.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Permissions Required:",
            style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.lightTheme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 1.h),
          _buildPermissionItem(
            icon: 'location_on',
            title: "Location Access",
            description: "Find nearby colleges",
          ),
          SizedBox(height: 1.h),
          _buildPermissionItem(
            icon: 'notifications',
            title: "Notifications",
            description: "Class reminders and updates",
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionItem({
    required String icon,
    required String title,
    required String description,
  }) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(2.w),
          decoration: BoxDecoration(
            color: AppTheme.lightTheme.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: CustomIconWidget(
            iconName: icon,
            color: AppTheme.lightTheme.primaryColor,
            size: 16,
          ),
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: AppTheme.lightTheme.colorScheme.onSurface,
                ),
              ),
              Text(
                description,
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
