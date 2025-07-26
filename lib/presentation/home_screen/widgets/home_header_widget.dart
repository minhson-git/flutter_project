import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class HomeHeaderWidget extends StatelessWidget {
  final VoidCallback? onSearchTap;
  final VoidCallback? onProfileTap;

  const HomeHeaderWidget({
    super.key,
    this.onSearchTap,
    this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // App Logo
          Row(
            children: [
              Container(
                width: 8.w,
                height: 8.w,
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.primaryColor,
                  borderRadius: BorderRadius.circular(2.w),
                ),
                child: Center(
                  child: Text(
                    'S',
                    style: TextStyle(
                      color: AppTheme.lightTheme.colorScheme.onPrimary,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 3.w),
              Text(
                'StreamVibe',
                style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          // Right side actions
          Row(
            children: [
              // Search Icon
              GestureDetector(
                onTap: onSearchTap,
                child: Container(
                  padding: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(2.w),
                  ),
                  child: CustomIconWidget(
                    iconName: 'search',
                    color: AppTheme.lightTheme.colorScheme.onSurface,
                    size: 20,
                  ),
                ),
              ),

              SizedBox(width: 3.w),

              // Profile Avatar
              GestureDetector(
                onTap: onProfileTap,
                child: Container(
                  width: 10.w,
                  height: 10.w,
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(5.w),
                    border: Border.all(
                      color: AppTheme.lightTheme.primaryColor,
                      width: 2,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(5.w),
                    child: CustomImageWidget(
                      imageUrl:
                          "https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=100&h=100&fit=crop&crop=face",
                      width: 10.w,
                      height: 10.w,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
