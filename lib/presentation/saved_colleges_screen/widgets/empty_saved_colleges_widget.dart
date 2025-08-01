import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class EmptySavedCollegesWidget extends StatelessWidget {
  final VoidCallback onExplorePressed;

  const EmptySavedCollegesWidget({
    Key? key,
    required this.onExplorePressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Illustration
            Container(
              width: 60.w,
              height: 30.h,
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomIconWidget(
                    iconName: 'school',
                    color: AppTheme.lightTheme.primaryColor,
                    size: 80,
                  ),
                  SizedBox(height: 16),
                  CustomIconWidget(
                    iconName: 'favorite_border',
                    color:
                        AppTheme.lightTheme.primaryColor.withValues(alpha: 0.6),
                    size: 40,
                  ),
                ],
              ),
            ),

            SizedBox(height: 32),

            // Title
            Text(
              'No Saved Colleges Yet',
              style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 12),

            // Description
            Text(
              'Start exploring colleges and save your favorites to compare them later. Build your personalized college list!',
              style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurface
                    .withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 32),

            // CTA Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onExplorePressed,
                icon: CustomIconWidget(
                  iconName: 'explore',
                  color: AppTheme.lightTheme.colorScheme.onPrimary,
                  size: 20,
                ),
                label: Text('Start Exploring Colleges'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),

            SizedBox(height: 16),

            // Secondary Action
            TextButton.icon(
              onPressed: () {
                // Navigate to popular colleges or recommendations
              },
              icon: CustomIconWidget(
                iconName: 'trending_up',
                color: AppTheme.lightTheme.primaryColor,
                size: 18,
              ),
              label: Text('View Popular Colleges'),
            ),

            SizedBox(height: 40),

            // Features List
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.lightTheme.colorScheme.outline
                      .withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Why Save Colleges?',
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 16),
                  _buildFeatureItem(
                    'compare_arrows',
                    'Compare fees and rankings',
                    'Side-by-side comparison of multiple colleges',
                  ),
                  SizedBox(height: 12),
                  _buildFeatureItem(
                    'bookmark',
                    'Quick access to favorites',
                    'Never lose track of colleges you\'re interested in',
                  ),
                  SizedBox(height: 12),
                  _buildFeatureItem(
                    'share',
                    'Share with family',
                    'Export your list and discuss with parents',
                  ),
                  SizedBox(height: 12),
                  _buildFeatureItem(
                    'offline_pin',
                    'Offline access',
                    'View saved college info even without internet',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(String iconName, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.lightTheme.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: CustomIconWidget(
            iconName: iconName,
            color: AppTheme.lightTheme.primaryColor,
            size: 20,
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 2),
              Text(
                description,
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurface
                      .withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
