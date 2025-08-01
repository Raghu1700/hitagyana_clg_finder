import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/app_export.dart';
import './widgets/college_hero_section_widget.dart';
import './widgets/college_info_card_widget.dart';
import './widgets/courses_section_widget.dart';
import './widgets/facilities_section_widget.dart';
import './widgets/fees_section_widget.dart';
import './widgets/location_section_widget.dart';

class CollegeDetailsScreen extends StatefulWidget {
  const CollegeDetailsScreen({Key? key}) : super(key: key);

  @override
  State<CollegeDetailsScreen> createState() => _CollegeDetailsScreenState();
}

class _CollegeDetailsScreenState extends State<CollegeDetailsScreen>
    with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  bool _isFavorite = false;
  bool _isLoading = false;
  late TabController _tabController;

  // Mock college data
  final Map<String, dynamic> collegeData = {
    "id": 1,
    "name": "Indian Institute of Technology Delhi",
    "shortName": "IIT Delhi",
    "images": [
      "https://images.pexels.com/photos/207692/pexels-photo-207692.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
      "https://images.pexels.com/photos/1454360/pexels-photo-1454360.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
      "https://images.pexels.com/photos/159490/yale-university-landscape-universities-schools-159490.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1"
    ],
    "description":
        "IIT Delhi is one of the premier engineering institutions in India, known for its excellence in technical education and research. Established in 1961, it has consistently ranked among the top engineering colleges globally.",
    "establishmentYear": 1961,
    "accreditation": "NAAC A++, NBA Accredited",
    "location": {
      "address": "Hauz Khas, New Delhi, Delhi 110016",
      "city": "New Delhi",
      "state": "Delhi",
      "latitude": 28.5449,
      "longitude": 77.1928
    },
    "fees": {
      "tuition": {"amount": 200000, "currency": "₹", "period": "per year"},
      "college": {"amount": 25000, "currency": "₹", "period": "per year"},
      "hostel": {"amount": 15000, "currency": "₹", "period": "per year"}
    },
    "facilities": [
      {
        "name": "Library",
        "icon": "library_books",
        "description": "24/7 Digital Library"
      },
      {
        "name": "Hostel",
        "icon": "hotel",
        "description": "On-campus accommodation"
      },
      {
        "name": "Sports",
        "icon": "sports_tennis",
        "description": "Multiple sports facilities"
      },
      {
        "name": "Labs",
        "icon": "science",
        "description": "State-of-the-art laboratories"
      },
      {"name": "WiFi", "icon": "wifi", "description": "High-speed internet"},
      {
        "name": "Cafeteria",
        "icon": "restaurant",
        "description": "Multi-cuisine dining"
      }
    ],
    "courses": [
      {
        "name": "Computer Science Engineering",
        "type": "undergraduate",
        "duration": "4 years",
        "seats": 120
      },
      {
        "name": "Mechanical Engineering",
        "type": "undergraduate",
        "duration": "4 years",
        "seats": 100
      },
      {
        "name": "M.Tech Computer Science",
        "type": "graduate",
        "duration": "2 years",
        "seats": 60
      },
      {"name": "MBA", "type": "graduate", "duration": "2 years", "seats": 80}
    ],
    "website": "https://www.iitd.ac.in",
    "contact": {"phone": "+91-11-2659-1000", "email": "info@iitd.ac.in"},
    "rank": 2,
    "lastUpdated": "2025-07-15"
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _toggleFavorite() {
    setState(() {
      _isFavorite = !_isFavorite;
    });

    HapticFeedback.lightImpact();
    Fluttertoast.showToast(
      msg: _isFavorite ? "Added to favorites" : "Removed from favorites",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  void _shareCollege() {
    HapticFeedback.selectionClick();
    final String shareText =
        "Check out ${collegeData['name']} - Rank #${collegeData['rank']} engineering college in India. Visit: ${collegeData['website']}";

    // Mock share functionality
    Fluttertoast.showToast(
      msg: "Sharing college details...",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  void _launchWebsite() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final Uri url = Uri.parse(collegeData['website']);
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        Fluttertoast.showToast(
          msg: "Could not open website",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Error opening website",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _contactCollege() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12.w,
              height: 0.5.h,
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 3.h),
            Text(
              "Contact ${collegeData['shortName']}",
              style: AppTheme.lightTheme.textTheme.titleLarge,
            ),
            SizedBox(height: 3.h),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'phone',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 24,
              ),
              title: Text("Call"),
              subtitle: Text(collegeData['contact']['phone']),
              onTap: () {
                Navigator.pop(context);
                Fluttertoast.showToast(msg: "Calling college...");
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'email',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 24,
              ),
              title: Text("Email"),
              subtitle: Text(collegeData['contact']['email']),
              onTap: () {
                Navigator.pop(context);
                Fluttertoast.showToast(msg: "Opening email app...");
              },
            ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              // Custom App Bar
              SliverAppBar(
                expandedHeight: 8.h,
                floating: false,
                pinned: true,
                backgroundColor: AppTheme.lightTheme.colorScheme.surface,
                elevation: 0,
                leading: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: CustomIconWidget(
                    iconName: 'arrow_back',
                    color: AppTheme.lightTheme.colorScheme.onSurface,
                    size: 24,
                  ),
                ),
                title: Text(
                  collegeData['shortName'],
                  style: AppTheme.lightTheme.textTheme.titleLarge,
                ),
                actions: [
                  IconButton(
                    onPressed: _toggleFavorite,
                    icon: CustomIconWidget(
                      iconName: _isFavorite ? 'favorite' : 'favorite_border',
                      color: _isFavorite
                          ? AppTheme.lightTheme.colorScheme.error
                          : AppTheme.lightTheme.colorScheme.onSurface,
                      size: 24,
                    ),
                  ),
                  IconButton(
                    onPressed: _shareCollege,
                    icon: CustomIconWidget(
                      iconName: 'share',
                      color: AppTheme.lightTheme.colorScheme.onSurface,
                      size: 24,
                    ),
                  ),
                  SizedBox(width: 2.w),
                ],
              ),

              // Hero Section
              SliverToBoxAdapter(
                child: CollegeHeroSectionWidget(
                  images: (collegeData['images'] as List).cast<String>(),
                ),
              ),

              // College Info Card
              SliverToBoxAdapter(
                child: CollegeInfoCardWidget(
                  name: collegeData['name'],
                  description: collegeData['description'],
                  establishmentYear: collegeData['establishmentYear'],
                  accreditation: collegeData['accreditation'],
                  rank: collegeData['rank'],
                ),
              ),

              // Fees Section
              SliverToBoxAdapter(
                child: FeesSectionWidget(
                  fees: collegeData['fees'],
                ),
              ),

              // Location Section
              SliverToBoxAdapter(
                child: LocationSectionWidget(
                  location: collegeData['location'],
                ),
              ),

              // Facilities Section
              SliverToBoxAdapter(
                child: FacilitiesSectionWidget(
                  facilities: (collegeData['facilities'] as List)
                      .cast<Map<String, dynamic>>(),
                ),
              ),

              // Courses Section
              SliverToBoxAdapter(
                child: CoursesSectionWidget(
                  courses: (collegeData['courses'] as List)
                      .cast<Map<String, dynamic>>(),
                  tabController: _tabController,
                ),
              ),

              // Last Updated Info
              SliverToBoxAdapter(
                child: Container(
                  margin: EdgeInsets.all(4.w),
                  padding: EdgeInsets.all(3.w),
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.lightTheme.colorScheme.outline
                          .withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'info_outline',
                        color: AppTheme.lightTheme.colorScheme.primary,
                        size: 16,
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        "Last updated: ${collegeData['lastUpdated']}",
                        style: AppTheme.lightTheme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom spacing for sticky buttons
              SliverToBoxAdapter(
                child: SizedBox(height: 12.h),
              ),
            ],
          ),

          // Floating Contact Button
          Positioned(
            right: 4.w,
            bottom: 18.h,
            child: FloatingActionButton(
              onPressed: _contactCollege,
              backgroundColor: AppTheme.lightTheme.colorScheme.secondary,
              child: CustomIconWidget(
                iconName: 'phone',
                color: AppTheme.lightTheme.colorScheme.onSecondary,
                size: 24,
              ),
            ),
          ),

          // Bottom Sticky Buttons
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.lightTheme.colorScheme.shadow,
                    blurRadius: 8,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _toggleFavorite,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CustomIconWidget(
                              iconName:
                                  _isFavorite ? 'favorite' : 'favorite_border',
                              color: AppTheme.lightTheme.colorScheme.primary,
                              size: 20,
                            ),
                            SizedBox(width: 2.w),
                            Text(
                                _isFavorite ? "Favorited" : "Add to Favorites"),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _launchWebsite,
                        child: _isLoading
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppTheme.lightTheme.colorScheme.onPrimary,
                                  ),
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CustomIconWidget(
                                    iconName: 'language',
                                    color: AppTheme
                                        .lightTheme.colorScheme.onPrimary,
                                    size: 20,
                                  ),
                                  SizedBox(width: 2.w),
                                  Text("Visit Website"),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
