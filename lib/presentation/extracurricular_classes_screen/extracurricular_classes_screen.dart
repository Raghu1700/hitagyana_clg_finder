import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/category_chip_widget.dart';
import './widgets/class_card_widget.dart';
import './widgets/filter_bottom_sheet_widget.dart';

class ExtracurricularClassesScreen extends StatefulWidget {
  const ExtracurricularClassesScreen({Key? key}) : super(key: key);

  @override
  State<ExtracurricularClassesScreen> createState() =>
      _ExtracurricularClassesScreenState();
}

class _ExtracurricularClassesScreenState
    extends State<ExtracurricularClassesScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  String _selectedCategory = 'All';
  String _searchQuery = '';
  bool _isLoading = false;
  bool _isRefreshing = false;

  final List<String> _categories = [
    'All',
    'Arts',
    'Technology',
    'Sports',
    'Music',
    'Leadership'
  ];

  final List<Map<String, dynamic>> _mockClasses = [
    {
      "id": 1,
      "title": "Digital Art Fundamentals",
      "instructor": "Sarah Johnson",
      "instructorImage":
          "https://images.pexels.com/photos/774909/pexels-photo-774909.jpeg?auto=compress&cs=tinysrgb&w=400",
      "thumbnail":
          "https://images.pexels.com/photos/1181298/pexels-photo-1181298.jpeg?auto=compress&cs=tinysrgb&w=400",
      "duration": "6 weeks",
      "skillLevel": "Beginner",
      "rating": 4.8,
      "enrollmentCount": 1250,
      "category": "Arts",
      "price": "₹2,999",
      "description":
          "Learn the fundamentals of digital art creation using industry-standard tools and techniques.",
      "prerequisites": ["Basic computer skills", "Creative mindset"],
      "schedule": "Mon, Wed, Fri - 7:00 PM",
      "isEnrolled": false,
      "isWishlisted": false
    },
    {
      "id": 2,
      "title": "Python Programming Bootcamp",
      "instructor": "Michael Chen",
      "instructorImage":
          "https://images.pexels.com/photos/1222271/pexels-photo-1222271.jpeg?auto=compress&cs=tinysrgb&w=400",
      "thumbnail":
          "https://images.pexels.com/photos/1181671/pexels-photo-1181671.jpeg?auto=compress&cs=tinysrgb&w=400",
      "duration": "8 weeks",
      "skillLevel": "Intermediate",
      "rating": 4.9,
      "enrollmentCount": 2100,
      "category": "Technology",
      "price": "₹4,999",
      "description":
          "Master Python programming with hands-on projects and real-world applications.",
      "prerequisites": [
        "Basic programming knowledge",
        "Computer with Python installed"
      ],
      "schedule": "Tue, Thu - 8:00 PM",
      "isEnrolled": true,
      "isWishlisted": false
    },
    {
      "id": 3,
      "title": "Basketball Training Academy",
      "instructor": "James Rodriguez",
      "instructorImage":
          "https://images.pexels.com/photos/1043471/pexels-photo-1043471.jpeg?auto=compress&cs=tinysrgb&w=400",
      "thumbnail":
          "https://images.pexels.com/photos/1752757/pexels-photo-1752757.jpeg?auto=compress&cs=tinysrgb&w=400",
      "duration": "12 weeks",
      "skillLevel": "All Levels",
      "rating": 4.7,
      "enrollmentCount": 850,
      "category": "Sports",
      "price": "₹3,499",
      "description":
          "Improve your basketball skills with professional coaching and structured training.",
      "prerequisites": ["Basic fitness level", "Basketball shoes"],
      "schedule": "Sat, Sun - 6:00 AM",
      "isEnrolled": false,
      "isWishlisted": true
    },
    {
      "id": 4,
      "title": "Guitar Mastery Course",
      "instructor": "Emma Wilson",
      "instructorImage":
          "https://images.pexels.com/photos/1239291/pexels-photo-1239291.jpeg?auto=compress&cs=tinysrgb&w=400",
      "thumbnail":
          "https://images.pexels.com/photos/1407322/pexels-photo-1407322.jpeg?auto=compress&cs=tinysrgb&w=400",
      "duration": "10 weeks",
      "skillLevel": "Beginner",
      "rating": 4.6,
      "enrollmentCount": 1680,
      "category": "Music",
      "price": "₹3,999",
      "description":
          "Learn to play guitar from scratch with step-by-step lessons and practice sessions.",
      "prerequisites": ["Acoustic or electric guitar", "Pick and tuner"],
      "schedule": "Mon, Wed, Fri - 6:30 PM",
      "isEnrolled": false,
      "isWishlisted": false
    },
    {
      "id": 5,
      "title": "Leadership Excellence Program",
      "instructor": "David Kumar",
      "instructorImage":
          "https://images.pexels.com/photos/1681010/pexels-photo-1681010.jpeg?auto=compress&cs=tinysrgb&w=400",
      "thumbnail":
          "https://images.pexels.com/photos/1181396/pexels-photo-1181396.jpeg?auto=compress&cs=tinysrgb&w=400",
      "duration": "4 weeks",
      "skillLevel": "Advanced",
      "rating": 4.9,
      "enrollmentCount": 920,
      "category": "Leadership",
      "price": "₹5,999",
      "description":
          "Develop essential leadership skills for personal and professional growth.",
      "prerequisites": ["Work experience", "Team management exposure"],
      "schedule": "Tue, Thu - 7:30 PM",
      "isEnrolled": true,
      "isWishlisted": false
    },
    {
      "id": 6,
      "title": "Watercolor Painting Workshop",
      "instructor": "Lisa Anderson",
      "instructorImage":
          "https://images.pexels.com/photos/1181686/pexels-photo-1181686.jpeg?auto=compress&cs=tinysrgb&w=400",
      "thumbnail":
          "https://images.pexels.com/photos/1183992/pexels-photo-1183992.jpeg?auto=compress&cs=tinysrgb&w=400",
      "duration": "5 weeks",
      "skillLevel": "Beginner",
      "rating": 4.5,
      "enrollmentCount": 640,
      "category": "Arts",
      "price": "₹2,499",
      "description":
          "Explore the beautiful world of watercolor painting with professional techniques.",
      "prerequisites": ["Watercolor paints", "Brushes and paper"],
      "schedule": "Sat - 10:00 AM",
      "isEnrolled": false,
      "isWishlisted": false
    }
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: 1);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _loadMoreClasses();
    }
  }

  Future<void> _loadMoreClasses() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _refreshClasses() async {
    setState(() {
      _isRefreshing = true;
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _isRefreshing = false;
    });
  }

  List<Map<String, dynamic>> get _filteredClasses {
    return _mockClasses.where((classItem) {
      final matchesCategory = _selectedCategory == 'All' ||
          (classItem['category'] as String) == _selectedCategory;
      final matchesSearch = _searchQuery.isEmpty ||
          (classItem['title'] as String)
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          (classItem['instructor'] as String)
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          (classItem['category'] as String)
              .toLowerCase()
              .contains(_searchQuery.toLowerCase());

      return matchesCategory && matchesSearch;
    }).toList();
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterBottomSheetWidget(
        onApplyFilters: (filters) {
          // Apply filters logic here
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildTabBar(),
          _buildSearchAndFilter(),
          _buildCategoryChips(),
          Expanded(
            child: _buildClassesList(),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppTheme.lightTheme.appBarTheme.backgroundColor,
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
        'Hitagyana Clg Finder',
        style: AppTheme.lightTheme.appBarTheme.titleTextStyle,
      ),
      actions: [
        IconButton(
          onPressed: () {},
          icon: CustomIconWidget(
            iconName: 'notifications_outlined',
            color: AppTheme.lightTheme.colorScheme.onSurface,
            size: 24,
          ),
        ),
        SizedBox(width: 2.w),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: AppTheme.lightTheme.colorScheme.surface,
      child: TabBar(
        controller: _tabController,
        tabs: const [
          Tab(text: 'Colleges'),
          Tab(text: 'Classes'),
          Tab(text: 'Saved'),
        ],
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacementNamed(
                context, '/college-search-dashboard');
          } else if (index == 2) {
            Navigator.pushReplacementNamed(context, '/saved-colleges-screen');
          }
        },
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Container(
      padding: EdgeInsets.all(4.w),
      color: AppTheme.lightTheme.colorScheme.surface,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search classes, instructors...',
                prefixIcon: Padding(
                  padding: EdgeInsets.all(3.w),
                  child: CustomIconWidget(
                    iconName: 'search',
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                        icon: CustomIconWidget(
                          iconName: 'clear',
                          color:
                              AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                          size: 20,
                        ),
                      )
                    : null,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppTheme.lightTheme.colorScheme.outline,
                    width: 1,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppTheme.lightTheme.colorScheme.outline,
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppTheme.lightTheme.colorScheme.primary,
                    width: 2,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 3.w),
          GestureDetector(
            onTap: _showFilterBottomSheet,
            child: Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: CustomIconWidget(
                iconName: 'filter_list',
                color: AppTheme.lightTheme.colorScheme.onPrimary,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChips() {
    return Container(
      height: 8.h,
      color: AppTheme.lightTheme.colorScheme.surface,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          return Padding(
            padding: EdgeInsets.only(right: 2.w),
            child: CategoryChipWidget(
              label: category,
              isSelected: _selectedCategory == category,
              onTap: () {
                setState(() {
                  _selectedCategory = category;
                });
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildClassesList() {
    final filteredClasses = _filteredClasses;

    if (filteredClasses.isEmpty && _searchQuery.isNotEmpty) {
      return _buildEmptySearchState();
    }

    if (filteredClasses.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _refreshClasses,
      color: AppTheme.lightTheme.colorScheme.primary,
      child: ListView.builder(
        controller: _scrollController,
        padding: EdgeInsets.all(4.w),
        itemCount: filteredClasses.length + (_isLoading ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == filteredClasses.length) {
            return _buildLoadingIndicator();
          }

          final classData = filteredClasses[index];
          return Padding(
            padding: EdgeInsets.only(bottom: 3.h),
            child: ClassCardWidget(
              classData: classData,
              onEnroll: () => _handleEnroll(classData),
              onWishlist: () => _handleWishlist(classData),
              onShare: () => _handleShare(classData),
              onInstructorProfile: () => _handleInstructorProfile(classData),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptySearchState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomIconWidget(
            iconName: 'search_off',
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            size: 64,
          ),
          SizedBox(height: 2.h),
          Text(
            'No classes found',
            style: AppTheme.lightTheme.textTheme.headlineSmall,
          ),
          SizedBox(height: 1.h),
          Text(
            'Try adjusting your search or filters',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 3.h),
          ElevatedButton(
            onPressed: () {
              _searchController.clear();
              setState(() {
                _searchQuery = '';
                _selectedCategory = 'All';
              });
            },
            child: const Text('Clear Filters'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomIconWidget(
            iconName: 'school',
            color: AppTheme.lightTheme.colorScheme.primary,
            size: 64,
          ),
          SizedBox(height: 2.h),
          Text(
            'Discover Amazing Classes',
            style: AppTheme.lightTheme.textTheme.headlineSmall,
          ),
          SizedBox(height: 1.h),
          Text(
            'Explore our wide range of extracurricular activities',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 3.h),
          ElevatedButton(
            onPressed: _refreshClasses,
            child: const Text('Browse Classes'),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: CircularProgressIndicator(
          color: AppTheme.lightTheme.colorScheme.primary,
        ),
      ),
    );
  }

  void _handleEnroll(Map<String, dynamic> classData) {
    // Handle enrollment logic
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Enrolled in ${classData['title']}'),
        backgroundColor: AppTheme.byzantium,
      ),
    );
  }

  void _handleWishlist(Map<String, dynamic> classData) {
    // Handle wishlist logic
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added ${classData['title']} to wishlist'),
      ),
    );
  }

  void _handleShare(Map<String, dynamic> classData) {
    // Handle share logic
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sharing ${classData['title']}'),
      ),
    );
  }

  void _handleInstructorProfile(Map<String, dynamic> classData) {
    // Handle instructor profile navigation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Viewing ${classData['instructor']} profile'),
      ),
    );
  }
}
