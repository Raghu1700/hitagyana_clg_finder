import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sizer/sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/app_export.dart';
import '../../services/firebase_service.dart';
import '../college_details_screen/college_details_screen.dart';
import 'widgets/college_card_widget.dart';
import 'widgets/recommendation_chip_widget.dart';
import 'widgets/search_filter_bottom_sheet.dart';

class CollegeSearchDashboard extends StatefulWidget {
  const CollegeSearchDashboard({super.key});

  @override
  State<CollegeSearchDashboard> createState() => _CollegeSearchDashboardState();
}

class _CollegeSearchDashboardState extends State<CollegeSearchDashboard>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool _isLoading = false;
  List<String> _savedColleges = [];

  final List<Map<String, dynamic>> _recommendationChips = [
    {"title": "Near Me", "icon": "location_on", "isActive": true},
    {"title": "Top Ranked", "icon": "star", "isActive": false},
    {"title": "Affordable", "icon": "attach_money", "isActive": false},
    {"title": "Engineering", "icon": "engineering", "isActive": false},
    {"title": "Medical", "icon": "local_hospital", "isActive": false},
    {"title": "Management", "icon": "business", "isActive": false},
  ];

  List<Map<String, dynamic>> _filteredColleges = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this, initialIndex: 0);
    _scrollController.addListener(_onScroll);
    _loadColleges();
    _loadSavedColleges();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedColleges() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _savedColleges = prefs.getStringList('savedColleges') ?? [];
    });
  }

  Future<void> _loadColleges() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final colleges = await FirebaseService.getAllColleges();
      setState(() {
        _filteredColleges = colleges;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      Fluttertoast.showToast(
        msg: "Error loading colleges: $e",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _loadMoreColleges();
    }
  }

  void _loadMoreColleges() {
    if (!_isLoading) {
      setState(() {
        _isLoading = true;
      });

      // Simulate loading more data
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _isLoading = false;
            Fluttertoast.showToast(
              msg: "All colleges loaded!",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
            );
          });
        }
      });
    }
  }

  Future<void> _onSearchChanged(String query) async {
    if (query.isEmpty) {
      _loadColleges();
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final colleges = await FirebaseService.searchColleges(query);
      setState(() {
        _filteredColleges = colleges;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      Fluttertoast.showToast(
        msg: "Error searching colleges: $e",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  Future<void> _onRecommendationChipTap(int index) async {
    setState(() {
      for (int i = 0; i < _recommendationChips.length; i++) {
        _recommendationChips[i]["isActive"] = i == index;
      }
      _isLoading = true;
    });

    try {
      final selectedChip = _recommendationChips[index];
      final category = selectedChip["title"] as String;

      final colleges = await FirebaseService.getCollegesByCategory(category);
      setState(() {
        _filteredColleges = colleges;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      Fluttertoast.showToast(
        msg: "Error filtering colleges: $e",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.lightTheme.appBarTheme.backgroundColor,
        elevation: 0,
        title: Text(
          "Hitagyana Clg Finder",
          style: AppTheme.lightTheme.appBarTheme.titleTextStyle,
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              icon: CustomIconWidget(
                iconName: 'search',
                size: 20,
                color: _tabController.index == 0
                    ? AppTheme.lightTheme.primaryColor
                    : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
              text: "Search",
            ),
            Tab(
              icon: CustomIconWidget(
                iconName: 'bookmark',
                size: 20,
                color: _tabController.index == 1
                    ? AppTheme.lightTheme.primaryColor
                    : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
              text: "Saved",
            ),
            Tab(
              icon: CustomIconWidget(
                iconName: 'school',
                size: 20,
                color: _tabController.index == 2
                    ? AppTheme.lightTheme.primaryColor
                    : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
              text: "Classes",
            ),
            Tab(
              icon: CustomIconWidget(
                iconName: 'person',
                size: 20,
                color: _tabController.index == 3
                    ? AppTheme.lightTheme.primaryColor
                    : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
              text: "Profile",
            ),
          ],
          onTap: (index) {
            switch (index) {
              case 1:
                Navigator.pushNamed(context, '/saved-colleges-screen');
                break;
              case 2:
                Navigator.pushNamed(context, '/extracurricular-classes-screen');
                break;
              case 3:
                // Handle profile navigation
                break;
            }
          },
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        physics:
            const NeverScrollableScrollPhysics(), // Disable swipe functionality
        children: [
          _buildSearchTab(),
          Container(), // Saved tab placeholder
          Container(), // Classes tab placeholder
          Container(), // Profile tab placeholder
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showFilterBottomSheet,
        backgroundColor: AppTheme.lightTheme.primaryColor,
        foregroundColor: AppTheme.lightTheme.colorScheme.onPrimary,
        icon: CustomIconWidget(
          iconName: 'tune',
          size: 20,
          color: AppTheme.lightTheme.colorScheme.onPrimary,
        ),
        label: Text(
          "Advanced Search",
          style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildSearchTab() {
    return RefreshIndicator(
      onRefresh: _loadColleges,
      child: Column(
        children: [
          _buildSearchBar(),
          _buildRecommendationChips(),
          Expanded(
            child: _isLoading && _filteredColleges.isEmpty
                ? _buildLoadingIndicator()
                : _filteredColleges.isEmpty
                    ? _buildEmptyState()
                    : _buildCollegeList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color:
                AppTheme.lightTheme.colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: _onSearchChanged,
        decoration: InputDecoration(
          hintText: "Search colleges, courses, or locations...",
          hintStyle: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
          ),
          prefixIcon: CustomIconWidget(
            iconName: 'search',
            size: 20,
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    _searchController.clear();
                    _onSearchChanged("");
                  },
                  child: CustomIconWidget(
                    iconName: 'close',
                    size: 20,
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  ),
                )
              : null,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        ),
      ),
    );
  }

  Widget _buildRecommendationChips() {
    return SizedBox(
      height: 6.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _recommendationChips.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.only(right: 2.w),
            child: RecommendationChipWidget(
              chip: _recommendationChips[index],
              onTap: () => _onRecommendationChipTap(index),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCollegeList() {
    return ListView.builder(
      controller: _scrollController,
      itemCount: _filteredColleges.length + (_isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _filteredColleges.length) {
          return _buildLoadingCard();
        }

        final college = _filteredColleges[index];
        final isSaved = _savedColleges.contains(college["id"].toString());

        return CollegeCardWidget(
          college: college,
          isSaved: isSaved,
          onSaveToggle: () => _toggleSaveCollege(college["id"].toString()),
          onTap: () => _navigateToCollegeDetails(college),
        );
      },
    );
  }

  Widget _buildLoadingIndicator() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomIconWidget(
            iconName: 'search_off',
            size: 80,
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
          ),
          SizedBox(height: 2.h),
          Text(
            "No colleges found",
            style: AppTheme.lightTheme.textTheme.headlineSmall,
          ),
          SizedBox(height: 1.h),
          Text(
            "Try adjusting your search criteria\nor explore different filters",
            style: AppTheme.lightTheme.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 3.h),
          ElevatedButton(
            onPressed: () {
              _searchController.clear();
              _onSearchChanged("");
            },
            child: const Text("Clear Search"),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Future<void> _toggleSaveCollege(String collegeId) async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      if (_savedColleges.contains(collegeId)) {
        _savedColleges.remove(collegeId);
        Fluttertoast.showToast(msg: "College removed from saved list");
      } else {
        _savedColleges.add(collegeId);
        Fluttertoast.showToast(msg: "College saved successfully");
      }
    });

    // Save to SharedPreferences
    await prefs.setStringList('savedColleges', _savedColleges);
  }

  void _navigateToCollegeDetails(Map<String, dynamic> college) {
    Navigator.pushNamed(context, '/college-details-screen');
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SearchFilterBottomSheet(
        onFiltersApplied: (filters) {
          // Handle filter application
          Navigator.pop(context);
          Fluttertoast.showToast(msg: "Filters applied successfully");
        },
      ),
    );
  }
}
