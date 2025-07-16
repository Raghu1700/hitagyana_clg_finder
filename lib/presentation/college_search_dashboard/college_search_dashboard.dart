import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../data/models/college_model.dart';
import '../../data/services/firebase_college_service.dart';
import './widgets/college_card_widget.dart';
import './widgets/recommendation_chip_widget.dart';
import './widgets/search_filter_bottom_sheet.dart';

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
  bool _isLoading = true;
  int _activeFilters = 0;
  List<String> _savedColleges = [];

  // Firebase service
  final FirebaseCollegeService _collegeService = FirebaseCollegeService();

  // College data
  List<CollegeModel> _colleges = [];
  List<CollegeModel> _filteredColleges = [];

  final List<Map<String, dynamic>> _recommendationChips = [
    {"title": "Near Me", "icon": "location_on", "isActive": true},
    {"title": "Top Ranked", "icon": "star", "isActive": false},
    {"title": "Affordable", "icon": "attach_money", "isActive": false},
    {"title": "Engineering", "icon": "engineering", "isActive": false},
    {"title": "Medical", "icon": "local_hospital", "isActive": false},
    {"title": "Management", "icon": "business", "isActive": false},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this, initialIndex: 0);
    // _scrollController.addListener(_onScroll);
    _loadColleges();
  }

  Future<void> _loadColleges() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final colleges = await _collegeService.getAllColleges();

      setState(() {
        _colleges = colleges;
        _filteredColleges = List.from(colleges);
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading colleges: $e');
      setState(() {
        _isLoading = false;
      });
    }
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
          });
        }
      });
    }
  }

  void _onSearchChanged(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredColleges = List.from(_colleges);
      } else {
        _filteredColleges = _colleges.where((college) {
          final name = college.name.toLowerCase();
          final location = college.location.toLowerCase();
          final searchQuery = query.toLowerCase();
          return name.contains(searchQuery) || location.contains(searchQuery);
        }).toList();
      }
    });
  }

  void _onRefresh() async {
    setState(() {
      _isLoading = true;
    });

    await _loadColleges();
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SearchFilterBottomSheet(
        onFiltersApplied: (filterCount) {
          setState(() {
            _activeFilters = filterCount;
          });
        },
      ),
    );
  }

  void _toggleSaveCollege(String collegeId) {
    setState(() {
      if (_savedColleges.contains(collegeId)) {
        _savedColleges.remove(collegeId);
      } else {
        _savedColleges.add(collegeId);
      }
    });
  }

  void _onRecommendationChipTap(int index) async {
    // Instantly update the UI to reflect the active chip
    setState(() {
      for (int i = 0; i < _recommendationChips.length; i++) {
        _recommendationChips[i]["isActive"] = i == index;
      }
    });

    // A small delay to ensure the UI updates before the async operation
    await Future.delayed(const Duration(milliseconds: 50));

    setState(() {
      _isLoading = true;
    });

    try {
      // Filter colleges based on selected chip
      final selectedChip = _recommendationChips[index];
      List<CollegeModel> recommendedColleges;

      switch (selectedChip["title"]) {
        case "Top Ranked":
          recommendedColleges = await _collegeService.getRecommendedColleges(
              category: 'Top Ranked');
          break;
        case "Affordable":
          recommendedColleges = await _collegeService.getRecommendedColleges(
              category: 'Affordable');
          break;
        case "Engineering":
          recommendedColleges = await _collegeService.getRecommendedColleges(
              category: 'Engineering');
          break;
        case "Medical":
          recommendedColleges =
              await _collegeService.getRecommendedColleges(category: 'Medical');
          break;
        case "Management":
          recommendedColleges = await _collegeService.getRecommendedColleges(
              category: 'Management');
          break;
        default:
          recommendedColleges = List.from(_colleges);
      }

      setState(() {
        _filteredColleges = recommendedColleges;
        _isLoading = false;
      });
    } catch (e) {
      print('Error getting recommended colleges: $e');
      setState(() {
        _filteredColleges = List.from(_colleges);
        _isLoading = false;
      });
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
          "Hitagyana College Finder",
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
                    ? AppTheme.secondaryLight
                    : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
              text: "Search",
            ),
            Tab(
              icon: CustomIconWidget(
                iconName: 'bookmark',
                size: 20,
                color: _tabController.index == 1
                    ? AppTheme.secondaryLight
                    : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
              text: "Saved",
            ),
            Tab(
              icon: CustomIconWidget(
                iconName: 'school',
                size: 20,
                color: _tabController.index == 2
                    ? AppTheme.secondaryLight
                    : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
              text: "Classes",
            ),
            Tab(
              icon: CustomIconWidget(
                iconName: 'person',
                size: 20,
                color: _tabController.index == 3
                    ? AppTheme.secondaryLight
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
      onRefresh: () async => _onRefresh(),
      color: AppTheme.lightTheme.primaryColor,
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverPersistentHeader(
            pinned: true,
            delegate: _StickyHeaderDelegate(
              child: Container(
                color: AppTheme.lightTheme.scaffoldBackgroundColor,
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                child: Column(
                  children: [
                    _buildSearchBar(),
                    SizedBox(height: 2.h),
                    _buildRecommendationChips(),
                  ],
                ),
              ),
            ),
          ),
          _isLoading
              ? SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              : _filteredColleges.isEmpty
                  ? SliverFillRemaining(
                      child: _buildEmptyState(),
                    )
                  : SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          if (index < _filteredColleges.length) {
                            final college = _filteredColleges[index];
                            return CollegeCardWidget(
                              college: {
                                "id": college.id,
                                "name": college.name,
                                "shortName": college.shortName,
                                "location": college.location,
                                "ranking": college.ranking,
                                "logo": college.logo,
                                "tuitionFee": college.tuitionFee,
                                "collegeFee": college.collegeFee,
                                "hostelFee": college.hostelFee,
                                "totalFee": college.totalFee,
                                "courses": college.courses,
                                "rating": college.rating,
                                "website": college.website,
                                "established": college.established,
                                "type": college.type,
                                "accreditation": college.accreditation,
                              },
                              isSaved: _savedColleges.contains(college.id),
                              onSaveToggle: () =>
                                  _toggleSaveCollege(college.id),
                              onTap: () {
                                Navigator.pushNamed(
                                    context, '/college-details-screen');
                              },
                            );
                          } else if (_isLoading) {
                            return _buildLoadingCard();
                          }
                          return null;
                        },
                        childCount:
                            _filteredColleges.length + (_isLoading ? 3 : 0),
                      ),
                    ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
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
          hintText: "Search colleges, cities, or states...",
          prefixIcon: Padding(
            padding: EdgeInsets.all(3.w),
            child: CustomIconWidget(
              iconName: 'search',
              size: 20,
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
          ),
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () {},
                icon: CustomIconWidget(
                  iconName: 'mic',
                  size: 20,
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
              ),
              Stack(
                children: [
                  IconButton(
                    onPressed: _showFilterBottomSheet,
                    icon: CustomIconWidget(
                      iconName: 'filter_list',
                      size: 20,
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  _activeFilters > 0
                      ? Positioned(
                          right: 8,
                          top: 8,
                          child: Container(
                            padding: EdgeInsets.all(1.w),
                            decoration: BoxDecoration(
                              color: AppTheme.lightTheme.colorScheme.error,
                              shape: BoxShape.circle,
                            ),
                            constraints: BoxConstraints(
                              minWidth: 4.w,
                              minHeight: 4.w,
                            ),
                            child: Text(
                              _activeFilters.toString(),
                              style: AppTheme.lightTheme.textTheme.labelSmall
                                  ?.copyWith(
                                color: AppTheme.lightTheme.colorScheme.onError,
                                fontSize: 8.sp,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                ],
              ),
            ],
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        ),
      ),
    );
  }

  Widget _buildRecommendationChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Row(
        children: _recommendationChips.asMap().entries.map((entry) {
          int index = entry.key;
          Map<String, dynamic> chip = entry.value;
          return Padding(
            padding: EdgeInsets.only(right: 2.w),
            child: RecommendationChipWidget(
              chip: chip,
              isActive: chip['isActive'] as bool,
              onTap: () => _onRecommendationChipTap(index),
            ),
          );
        }).toList(),
      ),
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
        boxShadow: [
          BoxShadow(
            color:
                AppTheme.lightTheme.colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 15.w,
                height: 15.w,
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 60.w,
                      height: 2.h,
                      decoration: BoxDecoration(
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Container(
                      width: 40.w,
                      height: 1.5.h,
                      decoration: BoxDecoration(
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Container(
            width: double.infinity,
            height: 1.5.h,
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant
                  .withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }
}

class _StickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _StickyHeaderDelegate({required this.child});

  @override
  double get minExtent => 20.h;

  @override
  double get maxExtent => 20.h;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}
