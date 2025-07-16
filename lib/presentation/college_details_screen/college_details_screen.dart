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
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Padding(
          padding: EdgeInsets.only(bottom: 12.h), // Space for bottom bar
          child: Column(
            children: [
              // Use a basic app bar for simplicity
              AppBar(
                title: Text(collegeData['name']),
                actions: [
                  IconButton(
                    icon: Icon(Icons.share),
                    onPressed: _shareCollege,
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CollegeHeroSectionWidget(
                        images: (collegeData['images'] as List).cast<String>()),
                    SizedBox(height: 3.h),
                    _buildInfoSection(),
                    SizedBox(height: 3.h),
                    _buildTabs(),
                    SizedBox(
                      height: 50.h,
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildCoursesSection(),
                          _buildFacilitiesAndFeesSection(),
                        ],
                      ),
                    ),
                    SizedBox(height: 3.h),
                    _buildLocationSection(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  // Refactored widgets for clarity
  Widget _buildInfoSection() {
    return CollegeInfoCardWidget(
      name: collegeData['name'],
      description: collegeData['description'],
      establishmentYear: collegeData['establishmentYear'],
      accreditation: collegeData['accreditation'],
      rank: collegeData['rank'],
    );
  }

  Widget _buildTabs() {
    return TabBar(
      controller: _tabController,
      tabs: const [
        Tab(text: "Courses"),
        Tab(text: "Facilities & Fees"),
      ],
      labelColor: AppTheme.lightTheme.colorScheme.primary,
      unselectedLabelColor: AppTheme.lightTheme.colorScheme.onSurface,
      indicatorSize: TabBarIndicatorSize.label,
      indicatorColor: AppTheme.lightTheme.colorScheme.primary,
    );
  }

  Widget _buildCoursesSection() {
    return CoursesSectionWidget(
      courses: (collegeData['courses'] as List).cast<Map<String, dynamic>>(),
      tabController: _tabController,
    );
  }

  Widget _buildFacilitiesAndFeesSection() {
    return Column(
      children: [
        FacilitiesSectionWidget(
          facilities:
              (collegeData['facilities'] as List).cast<Map<String, dynamic>>(),
        ),
        SizedBox(height: 3.h),
        FeesSectionWidget(
          fees: collegeData['fees'],
        ),
      ],
    );
  }

  Widget _buildLocationSection() {
    return LocationSectionWidget(
      location: collegeData['location'],
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: AppTheme.lightTheme.colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _toggleFavorite,
              icon: Icon(
                _isFavorite ? Icons.favorite : Icons.favorite_border,
                color: _isFavorite
                    ? AppTheme.lightTheme.colorScheme.error
                    : AppTheme.lightTheme.colorScheme.primary,
              ),
              label: Text(
                _isFavorite ? "Saved" : "Favorite",
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: _isFavorite
                      ? AppTheme.lightTheme.colorScheme.error
                      : AppTheme.lightTheme.colorScheme.primary,
                ),
                foregroundColor: _isFavorite
                    ? AppTheme.lightTheme.colorScheme.error
                    : AppTheme.lightTheme.colorScheme.primary,
              ),
            ),
          ),
          SizedBox(width: 4.w),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _launchWebsite,
              icon: _isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppTheme.lightTheme.colorScheme.onPrimary,
                      ),
                    )
                  : const Icon(Icons.public),
              label: const Text("Visit Website"),
            ),
          ),
        ],
      ),
    );
  }
}
