import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class SearchFilterBottomSheet extends StatefulWidget {
  final Function(int) onFiltersApplied;

  const SearchFilterBottomSheet({
    super.key,
    required this.onFiltersApplied,
  });

  @override
  State<SearchFilterBottomSheet> createState() =>
      _SearchFilterBottomSheetState();
}

class _SearchFilterBottomSheetState extends State<SearchFilterBottomSheet> {
  double _locationRadius = 50.0;
  RangeValues _feeRange = const RangeValues(100000, 1000000);
  String _selectedRankingTier = "All";
  List<String> _selectedCourses = [];
  String _selectedType = "All";
  bool _hasHostel = false;
  bool _hasPlacement = false;

  final List<String> _rankingTiers = [
    "All",
    "Top 10",
    "Top 50",
    "Top 100",
    "Others"
  ];
  final List<String> _courseOptions = [
    "Engineering",
    "Medical",
    "Management",
    "Arts",
    "Science",
    "Commerce",
    "Law",
    "Architecture"
  ];
  final List<String> _typeOptions = ["All", "Government", "Private", "Deemed"];

  int get _activeFilterCount {
    int count = 0;
    if (_locationRadius != 50.0) count++;
    if (_feeRange.start != 100000 || _feeRange.end != 1000000) count++;
    if (_selectedRankingTier != "All") count++;
    if (_selectedCourses.isNotEmpty) count++;
    if (_selectedType != "All") count++;
    if (_hasHostel) count++;
    if (_hasPlacement) count++;
    return count;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 85.h,
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLocationSection(),
                  _buildFeeRangeSection(),
                  _buildRankingSection(),
                  _buildCourseSection(),
                  _buildTypeSection(),
                  _buildFacilitiesSection(),
                  SizedBox(height: 4.h),
                ],
              ),
            ),
          ),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color:
                AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: Row(
        children: [
          CustomIconWidget(
            iconName: 'tune',
            size: 24,
            color: AppTheme.lightTheme.primaryColor,
          ),
          SizedBox(width: 3.w),
          Text(
            "Search Filters",
            style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          TextButton(
            onPressed: _clearAllFilters,
            child: Text(
              "Clear All",
              style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.error,
              ),
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: CustomIconWidget(
              iconName: 'close',
              size: 20,
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationSection() {
    return _buildSection(
      title: "Location",
      icon: "location_on",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Search radius: ${_locationRadius.round()} km",
            style: AppTheme.lightTheme.textTheme.bodyMedium,
          ),
          SizedBox(height: 2.h),
          Slider(
            value: _locationRadius,
            min: 10,
            max: 500,
            divisions: 49,
            onChanged: (value) {
              setState(() {
                _locationRadius = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFeeRangeSection() {
    return _buildSection(
      title: "Fee Range",
      icon: "attach_money",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "₹${(_feeRange.start / 100000).toStringAsFixed(1)}L - ₹${(_feeRange.end / 100000).toStringAsFixed(1)}L per year",
            style: AppTheme.lightTheme.textTheme.bodyMedium,
          ),
          SizedBox(height: 2.h),
          RangeSlider(
            values: _feeRange,
            min: 50000,
            max: 2000000,
            divisions: 39,
            onChanged: (values) {
              setState(() {
                _feeRange = values;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRankingSection() {
    return _buildSection(
      title: "Ranking Tier",
      icon: "star",
      child: Wrap(
        spacing: 2.w,
        runSpacing: 1.h,
        children: _rankingTiers.map((tier) {
          final isSelected = _selectedRankingTier == tier;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedRankingTier = tier;
              });
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.lightTheme.primaryColor
                    : AppTheme.lightTheme.colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? AppTheme.lightTheme.primaryColor
                      : AppTheme.lightTheme.colorScheme.outline
                          .withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                tier,
                style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                  color: isSelected
                      ? AppTheme.lightTheme.colorScheme.onPrimary
                      : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCourseSection() {
    return _buildSection(
      title: "Courses Available",
      icon: "school",
      child: Wrap(
        spacing: 2.w,
        runSpacing: 1.h,
        children: _courseOptions.map((course) {
          final isSelected = _selectedCourses.contains(course);
          return GestureDetector(
            onTap: () {
              setState(() {
                isSelected
                    ? _selectedCourses.remove(course)
                    : _selectedCourses.add(course);
              });
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.lightTheme.primaryColor.withValues(alpha: 0.1)
                    : AppTheme.lightTheme.colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? AppTheme.lightTheme.primaryColor
                      : AppTheme.lightTheme.colorScheme.outline
                          .withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isSelected) ...[
                    CustomIconWidget(
                      iconName: 'check',
                      size: 14,
                      color: AppTheme.lightTheme.primaryColor,
                    ),
                    SizedBox(width: 1.w),
                  ],
                  Text(
                    course,
                    style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                      color: isSelected
                          ? AppTheme.lightTheme.primaryColor
                          : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTypeSection() {
    return _buildSection(
      title: "College Type",
      icon: "business",
      child: Wrap(
        spacing: 2.w,
        runSpacing: 1.h,
        children: _typeOptions.map((type) {
          final isSelected = _selectedType == type;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedType = type;
              });
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.lightTheme.primaryColor
                    : AppTheme.lightTheme.colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? AppTheme.lightTheme.primaryColor
                      : AppTheme.lightTheme.colorScheme.outline
                          .withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                type,
                style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                  color: isSelected
                      ? AppTheme.lightTheme.colorScheme.onPrimary
                      : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFacilitiesSection() {
    return _buildSection(
      title: "Facilities",
      icon: "home",
      child: Column(
        children: [
          _buildSwitchTile(
            title: "Hostel Available",
            value: _hasHostel,
            onChanged: (value) {
              setState(() {
                _hasHostel = value;
              });
            },
          ),
          _buildSwitchTile(
            title: "Placement Cell",
            value: _hasPlacement,
            onChanged: (value) {
              setState(() {
                _hasPlacement = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required String icon,
    required Widget child,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 3.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: icon,
                size: 20,
                color: AppTheme.lightTheme.primaryColor,
              ),
              SizedBox(width: 2.w),
              Text(
                title,
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          child,
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 1.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: AppTheme.lightTheme.textTheme.bodyMedium,
          ),
          Switch(
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color:
                AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _clearAllFilters,
              child: const Text("Reset"),
            ),
          ),
          SizedBox(width: 4.w),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: () {
                widget.onFiltersApplied(_activeFilterCount);
                Navigator.pop(context);
              },
              child: Text(
                _activeFilterCount > 0
                    ? "Apply Filters ($_activeFilterCount)"
                    : "Apply Filters",
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _clearAllFilters() {
    setState(() {
      _locationRadius = 50.0;
      _feeRange = const RangeValues(100000, 1000000);
      _selectedRankingTier = "All";
      _selectedCourses.clear();
      _selectedType = "All";
      _hasHostel = false;
      _hasPlacement = false;
    });
  }
}
