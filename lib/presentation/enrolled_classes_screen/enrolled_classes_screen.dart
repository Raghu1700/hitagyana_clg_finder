import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/auth_service.dart';
import '../../services/firebase_service.dart';
import '../course_page/course_page.dart';
import '../main_navigation/custom_page_route.dart';

class EnrolledClassesScreen extends StatefulWidget {
  const EnrolledClassesScreen({Key? key}) : super(key: key);

  @override
  State<EnrolledClassesScreen> createState() => _EnrolledClassesScreenState();
}

class _EnrolledClassesScreenState extends State<EnrolledClassesScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;
  List<Map<String, dynamic>> _enrolledCourses = [];
  List<Map<String, dynamic>> _filteredCourses = [];

  @override
  void initState() {
    super.initState();
    _loadEnrolledCourses();
    _searchController.addListener(_filterCourses);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadEnrolledCourses() async {
    setState(() => _isLoading = true);

    try {
      final user = AuthService.currentUser;
      if (user != null) {
        _enrolledCourses = await FirebaseService.getEnrolledCourses(user.uid);
        
        // Add mock enrolled course for testing
        _enrolledCourses.add({
          'id': 'mock_python',
          'name': 'Python Programming Bootcamp',
          'instructor': 'Michael Chen',
          'image': 'https://images.pexels.com/photos/1181671/pexels-photo-1181671.jpeg?auto=compress&cs=tinysrgb&w=400',
          'rating': 4.9,
          'category': 'Technology',
          'price': 4999,
          'progress': 35,
          'description': 'Master Python programming with hands-on projects and real-world applications.',
          'zoomMeetingId': '987 654 3210',
          'zoomMeetingLink': 'https://zoom.us/j/9876543210?pwd=xyz789',
          'zoomPassword': 'python123',
          'isRecurring': true,
          'recurringDays': ['Tuesday', 'Thursday'],
          'meetingTime': '8:00 PM - 9:30 PM',
          'timezone': 'IST',
        });
        
        setState(() {
          _filteredCourses = List.from(_enrolledCourses);
          _isLoading = false;
        });
        print('✅ Loaded ${_enrolledCourses.length} enrolled courses (including mock)');
      } else {
        setState(() {
          _enrolledCourses = [];
          _filteredCourses = [];
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading enrolled courses: $e');
      setState(() {
        _enrolledCourses = [];
        _filteredCourses = [];
        _isLoading = false;
      });
    }
  }

  void _filterCourses() {
    if (_searchController.text.isEmpty) {
      setState(() {
        _filteredCourses = List.from(_enrolledCourses);
      });
    } else {
      final query = _searchController.text.toLowerCase();
      setState(() {
        _filteredCourses = _enrolledCourses.where((course) {
          return course['name']?.toLowerCase().contains(query) ||
              course['instructor']?.toLowerCase().contains(query) ||
              course['category']?.toLowerCase().contains(query);
        }).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.almond,
      appBar: AppBar(
        backgroundColor: AppTheme.pureWhite,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          "My Classes",
          style: TextStyle(
            color: AppTheme.tyrianPurple,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _loadEnrolledCourses,
            icon: Icon(
              Icons.refresh,
              color: AppTheme.byzantium,
              size: 24,
            ),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: _isLoading
            ? Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.byzantium),
                ),
              )
            : _enrolledCourses.isEmpty
                ? _buildEmptyState()
                : Column(
                    children: [
                      // Search Bar
                      Container(
                        padding: EdgeInsets.all(4.w),
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppTheme.pureWhite,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: AppTheme.softShadow,
                          ),
                          child: TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: 'Search your enrolled courses...',
                              hintStyle: TextStyle(
                                color: AppTheme.byzantium.withOpacity(0.6),
                                fontSize: 14,
                              ),
                              prefixIcon: Icon(
                                Icons.search,
                                color: AppTheme.byzantium,
                                size: 20,
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 4.w,
                                vertical: 3.h,
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Courses List
                      Expanded(
                        child: RefreshIndicator(
                          onRefresh: _loadEnrolledCourses,
                          color: AppTheme.byzantium,
                          child: ListView.builder(
                            padding: EdgeInsets.symmetric(horizontal: 4.w),
                            itemCount: _filteredCourses.length,
                            itemBuilder: (context, index) {
                              final course = _filteredCourses[index];
                              return Container(
                                margin: EdgeInsets.only(bottom: 3.h),
                                child: _buildCourseCard(course),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 30.w,
            height: 30.w,
            decoration: BoxDecoration(
              color: AppTheme.byzantium.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.school_outlined,
              size: 15.w,
              color: AppTheme.byzantium,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'No Enrolled Classes',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.tyrianPurple,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            'You haven\'t enrolled in any classes yet.\nStart learning by enrolling in a course!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.byzantium,
              height: 1.5,
            ),
          ),
          SizedBox(height: 4.h),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/extracurricular-classes-screen');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.tyrianPurple,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
            ),
            child: Text(
              'Browse Classes',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseCard(Map<String, dynamic> course) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          CustomPageRoute(
            child: CoursePage(course: course, isEnrolled: true),
            routeName: '/course-page',
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: AppTheme.pureWhite,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppTheme.softShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Course Image
                Container(
                  width: 20.w,
                  height: 20.w,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(
                      image: NetworkImage(course['image'] ??
                          'https://images.unsplash.com/photo-1522202176988-66273c2fd55f?w=800&h=600&fit=crop'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(width: 4.w),

                // Course Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        course['name'] ?? 'Course Name',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.tyrianPurple,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        'Instructor: ${course['instructor'] ?? 'Dr. John Doe'}',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.byzantium,
                        ),
                      ),
                      SizedBox(height: 0.5.h),
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.amber, size: 14),
                          SizedBox(width: 1.w),
                          Text(
                            '${course['rating'] ?? 4.5}',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.byzantium,
                            ),
                          ),
                          SizedBox(width: 2.w),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 2.w, vertical: 0.5.h),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Enrolled',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Access Button
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      CustomPageRoute(
                        child: CoursePage(course: course, isEnrolled: true),
                        routeName: '/course-page',
                      ),
                    );
                  },
                  icon: Icon(
                    Icons.play_circle_fill,
                    color: AppTheme.tyrianPurple,
                    size: 32,
                  ),
                ),
              ],
            ),

            SizedBox(height: 2.h),

            // Progress Bar
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Progress',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.byzantium,
                        ),
                      ),
                      SizedBox(height: 0.5.h),
                      LinearProgressIndicator(
                        value: (course['progress'] ?? 0.0) / 100,
                        backgroundColor: AppTheme.byzantium.withOpacity(0.2),
                        valueColor: AlwaysStoppedAnimation<Color>(
                            AppTheme.tyrianPurple),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 2.w),
                Text(
                  '${course['progress'] ?? 0}%',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.tyrianPurple,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
