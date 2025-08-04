import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class SavedCollegeCardWidget extends StatelessWidget {
  final Map<String, dynamic> college;
  final bool isEditMode;
  final bool isCompareMode;
  final bool isSelected;
  final VoidCallback onToggleSelection;
  final VoidCallback onRemove;
  final VoidCallback onShare;
  final VoidCallback onViewDetails;
  final VoidCallback onLongPress;

  const SavedCollegeCardWidget({
    Key? key,
    required this.college,
    required this.isEditMode,
    required this.isCompareMode,
    required this.isSelected,
    required this.onToggleSelection,
    required this.onRemove,
    required this.onShare,
    required this.onViewDetails,
    required this.onLongPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Safe null handling for college data
    final String collegeName = college['name']?.toString() ?? 'Unknown College';
    final String collegeLocation =
        college['location']?.toString() ?? 'Unknown Location';
    final String collegeType = college['type']?.toString() ?? 'University';
    final String collegeFees = college['fees']?.toString() ?? 'Not Available';
    final String collegeRanking =
        college['ranking']?.toString() ?? 'Not Ranked';
    final List<String> courses =
        _safeCastToStringList(college['courses'] ?? []);
    final String logoUrl = college['logo']?.toString() ?? '';

    return Container(
      margin: EdgeInsets.symmetric(vertical: 1.h),
      decoration: BoxDecoration(
        color: AppTheme.pureWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.softShadow,
        border:
            isSelected ? Border.all(color: AppTheme.byzantium, width: 2) : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isEditMode ? onToggleSelection : onViewDetails,
          onLongPress: onLongPress,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: EdgeInsets.all(4.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row
                Row(
                  children: [
                    // College Logo
                    Container(
                      width: 15.w,
                      height: 15.w,
                      decoration: BoxDecoration(
                        color: AppTheme.softGray,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppTheme.lightGray.withOpacity(0.3),
                        ),
                      ),
                      child: logoUrl.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                logoUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Icon(
                                  Icons.school,
                                  color: AppTheme.byzantium,
                                  size: 8.w,
                                ),
                              ),
                            )
                          : Icon(
                              Icons.school,
                              color: AppTheme.byzantium,
                              size: 8.w,
                            ),
                    ),

                    SizedBox(width: 3.w),

                    // College Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            collegeName,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.tyrianPurple,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 0.5.h),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                size: 4.w,
                                color: AppTheme.mediumGray,
                              ),
                              SizedBox(width: 1.w),
                              Expanded(
                                child: Text(
                                  collegeLocation,
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: AppTheme.mediumGray,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 0.5.h),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 2.w, vertical: 0.5.h),
                            decoration: BoxDecoration(
                              color: AppTheme.lavenderPink.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              collegeType,
                              style: TextStyle(
                                fontSize: 10.sp,
                                color: AppTheme.byzantium,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Action Buttons
                    Column(
                      children: [
                        if (isEditMode && isCompareMode)
                          Checkbox(
                            value: isSelected,
                            onChanged: (_) => onToggleSelection(),
                            activeColor: AppTheme.byzantium,
                          )
                        else if (isEditMode)
                          IconButton(
                            onPressed: onRemove,
                            icon: Icon(
                              Icons.delete,
                              color: Colors.red,
                              size: 6.w,
                            ),
                          )
                        else
                          IconButton(
                            onPressed: onShare,
                            icon: Icon(
                              Icons.share,
                              color: AppTheme.byzantium,
                              size: 5.w,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),

                SizedBox(height: 2.h),

                // College Details
                Row(
                  children: [
                    // Ranking
                    Expanded(
                      child: _buildInfoChip(
                        'Ranking',
                        collegeRanking,
                        Icons.emoji_events,
                        AppTheme.lavenderPink,
                      ),
                    ),
                    SizedBox(width: 2.w),
                    // Fees
                    Expanded(
                      child: _buildInfoChip(
                        'Fees',
                        collegeFees,
                        Icons.currency_rupee,
                        AppTheme.byzantium,
                      ),
                    ),
                  ],
                ),

                if (courses.isNotEmpty) ...[
                  SizedBox(height: 2.h),
                  Text(
                    'Popular Courses:',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.tyrianPurple,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Wrap(
                    spacing: 1.w,
                    runSpacing: 0.5.h,
                    children: courses.take(3).map((course) {
                      return Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 2.w, vertical: 0.5.h),
                        decoration: BoxDecoration(
                          color: AppTheme.champagnePink.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          course,
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: AppTheme.mediumGray,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(2.w),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 5.w,
            color: color,
          ),
          SizedBox(height: 0.5.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 10.sp,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 0.5.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 11.sp,
              color: AppTheme.darkGray,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // Safe method to convert dynamic list to List<String>
  List<String> _safeCastToStringList(dynamic list) {
    if (list == null) return [];
    if (list is List) {
      return list.map((item) => item?.toString() ?? '').toList();
    }
    return [];
  }
}
