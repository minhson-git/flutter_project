import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import './content_card_widget.dart';

enum CarouselType {
  continueWatching,
  trending,
  newReleases,
  actionAdventure,
}

class ContentCarouselWidget extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> contentData;
  final CarouselType carouselType;
  final Function(Map<String, dynamic>) onContentTap;
  final VoidCallback? onMoreTap;

  const ContentCarouselWidget({
    super.key,
    required this.title,
    required this.contentData,
    required this.carouselType,
    required this.onContentTap,
    this.onMoreTap,
  });

  @override
  Widget build(BuildContext context) {
    if (contentData.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (onMoreTap != null)
                TextButton(
                  onPressed: onMoreTap,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'See All',
                        style: TextStyle(
                          color: AppTheme.lightTheme.primaryColor,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(width: 1.w),
                      CustomIconWidget(
                        iconName: 'arrow_forward_ios',
                        color: AppTheme.lightTheme.primaryColor,
                        size: 14,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),

        SizedBox(height: 1.h),

        // Horizontal Scrollable Content
        SizedBox(
          height: _getCarouselHeight(),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            itemCount: contentData.length,
            itemBuilder: (context, index) {
              final content = contentData[index];
              return Container(
                margin: EdgeInsets.only(right: 3.w),
                child: ContentCardWidget(
                  content: content,
                  carouselType: carouselType,
                  onTap: () => onContentTap(content),
                  onLongPress: () => _showQuickActions(context, content),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  double _getCarouselHeight() {
    switch (carouselType) {
      case CarouselType.continueWatching:
        return 22.h;
      case CarouselType.trending:
      case CarouselType.newReleases:
      case CarouselType.actionAdventure:
        return 20.h;
    }
  }

  void _showQuickActions(BuildContext context, Map<String, dynamic> content) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.lightTheme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(4.w)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 12.w,
              height: 0.5.h,
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.outline,
                borderRadius: BorderRadius.circular(1.w),
              ),
            ),

            SizedBox(height: 2.h),

            // Content Info
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(2.w),
                  child: CustomImageWidget(
                    imageUrl: content["imageUrl"] as String? ?? "",
                    width: 15.w,
                    height: 20.w,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        content["title"] as String? ?? "",
                        style:
                        AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                          color: AppTheme.lightTheme.colorScheme.onSurface,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (content["genre"] != null) ...[
                        SizedBox(height: 0.5.h),
                        Text(
                          content["genre"] as String,
                          style:
                          AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            color: AppTheme.lightTheme.colorScheme.onSurface
                                .withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 3.h),

            // Quick Actions
            Column(
              children: [
                _buildQuickActionTile(
                  context,
                  icon: 'bookmark_add',
                  title: 'Add to Watchlist',
                  onTap: () {
                    Navigator.pop(context);
                    // Handle add to watchlist
                  },
                ),
                _buildQuickActionTile(
                  context,
                  icon: 'share',
                  title: 'Share',
                  onTap: () {
                    Navigator.pop(context);
                    // Handle share
                  },
                ),
                _buildQuickActionTile(
                  context,
                  icon: 'info',
                  title: 'More Info',
                  onTap: () {
                    Navigator.pop(context);
                    // Handle more info
                  },
                ),
              ],
            ),

            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionTile(
      BuildContext context, {
        required String icon,
        required String title,
        required VoidCallback onTap,
      }) {
    return ListTile(
      leading: CustomIconWidget(
        iconName: icon,
        color: AppTheme.lightTheme.colorScheme.onSurface,
        size: 24,
      ),
      title: Text(
        title,
        style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
          color: AppTheme.lightTheme.colorScheme.onSurface,
        ),
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(2.w),
      ),
    );
  }
}
