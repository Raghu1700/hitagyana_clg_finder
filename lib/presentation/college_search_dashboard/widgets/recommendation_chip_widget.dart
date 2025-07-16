import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class RecommendationChipWidget extends StatefulWidget {
  final Map<String, dynamic> chip;
  final VoidCallback onTap;
  final bool isActive;

  const RecommendationChipWidget({
    super.key,
    required this.chip,
    required this.onTap,
    required this.isActive,
  });

  @override
  State<RecommendationChipWidget> createState() =>
      _RecommendationChipWidgetState();
}

class _RecommendationChipWidgetState extends State<RecommendationChipWidget> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
        decoration: BoxDecoration(
          color: widget.isActive
              ? AppTheme.secondaryLight
              : AppTheme.lightTheme.colorScheme.surface.withOpacity(0.5),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: widget.isActive
                ? AppTheme.primaryVariantLight
                : AppTheme.lightTheme.colorScheme.outline
                    .withValues(alpha: 0.3),
            width: 1.5,
          ),
          boxShadow: widget.isActive
              ? [
                  BoxShadow(
                    color:
                        AppTheme.lightTheme.primaryColor.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomIconWidget(
              iconName: widget.chip["icon"] as String,
              size: 16,
              color: widget.isActive
                  ? AppTheme.onSecondaryLight
                  : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
            SizedBox(width: 2.w),
            Text(
              widget.chip["title"] as String,
              style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                color: widget.isActive
                    ? AppTheme.onSecondaryLight
                    : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                fontWeight: widget.isActive ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
