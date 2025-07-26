import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class CategoryCardWidget extends StatelessWidget {
  final Map<String, dynamic> category;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const CategoryCardWidget({
    super.key,
    required this.category,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final bool isFeatured = category["isFeatured"] as bool? ?? false;

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: isFeatured
              ? Border.all(
                  color: AppTheme.lightTheme.colorScheme.primary,
                  width: 2,
                )
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Background image
              CustomImageWidget(
                imageUrl: category["imageUrl"] as String,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
              ),

              // Gradient overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.3),
                      Colors.black.withValues(alpha: 0.8),
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              ),

              // Content
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Padding(
                  padding: EdgeInsets.all(3.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Featured badge
                      isFeatured
                          ? Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 2.w, vertical: 0.5.h),
                              decoration: BoxDecoration(
                                color: AppTheme.lightTheme.colorScheme.primary,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'FEATURED',
                                style: AppTheme.lightTheme.textTheme.labelSmall
                                    ?.copyWith(
                                  color:
                                      AppTheme.lightTheme.colorScheme.onPrimary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 8.sp,
                                ),
                              ),
                            )
                          : const SizedBox.shrink(),

                      isFeatured
                          ? SizedBox(height: 1.h)
                          : const SizedBox.shrink(),

                      // Category name
                      Text(
                        category["name"] as String,
                        style:
                            AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      SizedBox(height: 0.5.h),

                      // Content count
                      Row(
                        children: [
                          CustomIconWidget(
                            iconName: 'play_circle_outline',
                            color: Colors.white.withValues(alpha: 0.8),
                            size: 16,
                          ),
                          SizedBox(width: 1.w),
                          Text(
                            '${category["contentCount"]} titles',
                            style: AppTheme.lightTheme.textTheme.bodySmall
                                ?.copyWith(
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Ripple effect
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onTap,
                  onLongPress: onLongPress,
                  borderRadius: BorderRadius.circular(12),
                  splashColor: AppTheme.lightTheme.colorScheme.primary
                      .withValues(alpha: 0.2),
                  highlightColor: AppTheme.lightTheme.colorScheme.primary
                      .withValues(alpha: 0.1),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
