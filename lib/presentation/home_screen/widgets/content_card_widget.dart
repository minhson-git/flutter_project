import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import './content_carousel_widget.dart';

class ContentCardWidget extends StatelessWidget {
  final Map<String, dynamic> content;
  final CarouselType carouselType;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const ContentCardWidget({
    super.key,
    required this.content,
    required this.carouselType,
    required this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        width: 30.w,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(3.w),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Poster Image
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(3.w),
                    child: CustomImageWidget(
                      imageUrl: content["imageUrl"] as String? ?? "",
                      width: 30.w,
                      height: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),

                  // Progress Indicator for Continue Watching
                  if (carouselType == CarouselType.continueWatching &&
                      content["progress"] != null)
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 0.5.h,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(3.w),
                            bottomRight: Radius.circular(3.w),
                          ),
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor:
                              (content["progress"] as double).clamp(0.0, 1.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppTheme.lightTheme.primaryColor,
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(3.w),
                                bottomRight: content["progress"] >= 1.0
                                    ? Radius.circular(3.w)
                                    : Radius.zero,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                  // New Badge for New Releases
                  if (carouselType == CarouselType.newReleases &&
                      content["isNew"] == true)
                    Positioned(
                      top: 1.h,
                      right: 1.w,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 1.5.w, vertical: 0.5.h),
                        decoration: BoxDecoration(
                          color: AppTheme.lightTheme.primaryColor,
                          borderRadius: BorderRadius.circular(1.w),
                        ),
                        child: Text(
                          'NEW',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 8.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                  // Rating Badge for Trending and Action
                  if ((carouselType == CarouselType.trending ||
                          carouselType == CarouselType.actionAdventure) &&
                      content["rating"] != null)
                    Positioned(
                      top: 1.h,
                      left: 1.w,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 1.5.w, vertical: 0.5.h),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(1.w),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CustomIconWidget(
                              iconName: 'star',
                              color: Colors.amber,
                              size: 10,
                            ),
                            SizedBox(width: 0.5.w),
                            Text(
                              content["rating"].toString(),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 8.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Play Button Overlay
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(3.w),
                        color: Colors.black.withValues(alpha: 0.0),
                      ),
                      child: Center(
                        child: Container(
                          width: 12.w,
                          height: 12.w,
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.6),
                            shape: BoxShape.circle,
                          ),
                          child: CustomIconWidget(
                            iconName: 'play_arrow',
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 1.h),

            // Content Info
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 1.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    content["title"] as String? ?? "",
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  SizedBox(height: 0.5.h),

                  // Additional Info based on carousel type
                  if (carouselType == CarouselType.continueWatching) ...[
                    if (content["episode"] != null)
                      Text(
                        content["episode"] as String,
                        style:
                            AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.lightTheme.colorScheme.onSurface
                              .withValues(alpha: 0.7),
                        ),
                      ),
                  ] else if (carouselType == CarouselType.newReleases) ...[
                    if (content["genre"] != null)
                      Text(
                        content["genre"] as String,
                        style:
                            AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.lightTheme.primaryColor,
                        ),
                      ),
                  ] else ...[
                    if (content["year"] != null && content["genre"] != null)
                      Text(
                        "${content["year"]} • ${content["genre"]}",
                        style:
                            AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.lightTheme.colorScheme.onSurface
                              .withValues(alpha: 0.7),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
