import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/custom_icon_widget.dart';
import '../../../widgets/custom_image_widget.dart';

class ClassCardWidget extends StatelessWidget {
  final Map<String, dynamic> classData;
  final VoidCallback onEnroll;
  final VoidCallback onWishlist;
  final VoidCallback onShare;
  final VoidCallback onInstructorProfile;

  const ClassCardWidget({
    Key? key,
    required this.classData,
    required this.onEnroll,
    required this.onWishlist,
    required this.onShare,
    required this.onInstructorProfile,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isEnrolled = classData['isEnrolled'] ?? false;
    final bool isWishlisted = classData['isWishlisted'] ?? false;

    return GestureDetector(
      onTap: () => _showClassDetails(context),
      onLongPress: () => _showQuickActions(context),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildClassThumbnail(),
            _buildClassContent(isEnrolled, isWishlisted),
          ],
        ),
      ),
    );
  }

  Widget _buildClassThumbnail() {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          child: CustomImageWidget(
            imageUrl: classData['thumbnail'] ?? '',
            width: double.infinity,
            height: 25.h,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          top: 2.h,
          right: 3.w,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              classData['duration'] ?? '',
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 2.h,
          left: 3.w,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              classData['skillLevel'] ?? '',
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildClassContent(bool isEnrolled, bool isWishlisted) {
    return Padding(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInstructorInfo(),
          SizedBox(height: 2.h),
          _buildClassTitle(),
          SizedBox(height: 1.h),
          _buildRatingAndEnrollment(),
          SizedBox(height: 2.h),
          _buildPriceAndActions(isEnrolled, isWishlisted),
        ],
      ),
    );
  }

  Widget _buildInstructorInfo() {
    return GestureDetector(
      onTap: onInstructorProfile,
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: CustomImageWidget(
              imageUrl: classData['instructorImage'] ?? '',
              width: 8.w,
              height: 8.w,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  classData['instructor'] ?? '',
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Instructor',
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          CustomIconWidget(
            iconName: 'arrow_forward_ios',
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            size: 16,
          ),
        ],
      ),
    );
  }

  Widget _buildClassTitle() {
    return Text(
      classData['title'] ?? '',
      style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w600,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildRatingAndEnrollment() {
    return Row(
      children: [
        _buildRatingStars(),
        SizedBox(width: 2.w),
        Text(
          '${classData['rating'] ?? 0.0}',
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(width: 4.w),
        CustomIconWidget(
          iconName: 'people',
          color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
          size: 16,
        ),
        SizedBox(width: 1.w),
        Text(
          '${classData['enrollmentCount'] ?? 0} enrolled',
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildRatingStars() {
    final double rating = (classData['rating'] ?? 0.0).toDouble();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return CustomIconWidget(
          iconName: index < rating.floor() ? 'star' : 'star_border',
          color: AppTheme.lightTheme.colorScheme.secondary,
          size: 16,
        );
      }),
    );
  }

  Widget _buildPriceAndActions(bool isEnrolled, bool isWishlisted) {
    return Row(
      children: [
        Text(
          classData['price'] ?? '',
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            color: AppTheme.lightTheme.colorScheme.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const Spacer(),
        if (isEnrolled)
          ElevatedButton(
            onPressed: onEnroll,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.byzantium,
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
            ),
            child: const Text('Continue Learning'),
          )
        else
          Row(
            children: [
              IconButton(
                onPressed: onWishlist,
                icon: CustomIconWidget(
                  iconName: isWishlisted ? 'favorite' : 'favorite_border',
                  color: isWishlisted
                      ? Colors.red
                      : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  size: 24,
                ),
              ),
              SizedBox(width: 2.w),
              ElevatedButton(
                onPressed: onEnroll,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                ),
                child: const Text('Enroll Now'),
              ),
            ],
          ),
      ],
    );
  }

  void _showClassDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildClassDetailsSheet(context),
    );
  }

  Widget _buildClassDetailsSheet(BuildContext context) {
    return Container(
      height: 80.h,
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            width: 10.w,
            height: 0.5.h,
            margin: EdgeInsets.symmetric(vertical: 2.h),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailsThumbnail(),
                  SizedBox(height: 3.h),
                  _buildDetailsContent(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsThumbnail() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: CustomImageWidget(
        imageUrl: classData['thumbnail'] ?? '',
        width: double.infinity,
        height: 25.h,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildDetailsContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          classData['title'] ?? '',
          style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 2.h),
        _buildDetailRow('Instructor', classData['instructor'] ?? ''),
        _buildDetailRow('Duration', classData['duration'] ?? ''),
        _buildDetailRow('Skill Level', classData['skillLevel'] ?? ''),
        _buildDetailRow('Schedule', classData['schedule'] ?? ''),
        _buildDetailRow('Price', classData['price'] ?? ''),
        SizedBox(height: 3.h),
        Text(
          'Description',
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 1.h),
        Text(
          classData['description'] ?? '',
          style: AppTheme.lightTheme.textTheme.bodyMedium,
        ),
        SizedBox(height: 3.h),
        Text(
          'Prerequisites',
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 1.h),
        ...(classData['prerequisites'] as List<String>? ?? []).map(
          (prerequisite) => Padding(
            padding: EdgeInsets.only(bottom: 0.5.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('• ', style: AppTheme.lightTheme.textTheme.bodyMedium),
                Expanded(
                  child: Text(
                    prerequisite,
                    style: AppTheme.lightTheme.textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 4.h),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              onEnroll();
            },
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 2.h),
            ),
            child: Text(
              (classData['isEnrolled'] ?? false)
                  ? 'Continue Learning'
                  : 'Enroll Now',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 1.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 25.w,
            child: Text(
              label,
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showQuickActions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10.w,
              height: 0.5.h,
              margin: EdgeInsets.symmetric(vertical: 2.h),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'favorite_border',
                color: AppTheme.lightTheme.colorScheme.onSurface,
                size: 24,
              ),
              title: const Text('Add to Wishlist'),
              onTap: () {
                Navigator.pop(context);
                onWishlist();
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'share',
                color: AppTheme.lightTheme.colorScheme.onSurface,
                size: 24,
              ),
              title: const Text('Share Class'),
              onTap: () {
                Navigator.pop(context);
                onShare();
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'person',
                color: AppTheme.lightTheme.colorScheme.onSurface,
                size: 24,
              ),
              title: const Text('View Instructor Profile'),
              onTap: () {
                Navigator.pop(context);
                onInstructorProfile();
              },
            ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }
}
