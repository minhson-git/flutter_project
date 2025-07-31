import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../content_detail_screen.dart';

class MoreLikeThisWidget extends StatelessWidget {
  final List<MovieModel> relatedMovies;

  const MoreLikeThisWidget({
    super.key,
    required this.relatedMovies,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 2.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Text(
              "Phim tương tự",
              style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(height: 2.h),

          // Related Content List
          SizedBox(
            height: 28.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              itemCount: relatedMovies.length,
              separatorBuilder: (context, index) => SizedBox(width: 3.w),
              itemBuilder: (context, index) {
                final movie = relatedMovies[index];
                return _RelatedContentCard(movie: movie);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _RelatedContentCard extends StatelessWidget {
  final MovieModel movie;

  const _RelatedContentCard({required this.movie});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate to movie detail
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ContentDetailScreen(movieId: movie.id),
          ),
        );
      },
      onLongPress: () {
        _showQuickActionsMenu(context);
      },
      child: SizedBox(
        width: 35.w,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Movie Thumbnail
            Container(
              width: 35.w,
              height: 20.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: AppTheme.lightTheme.colorScheme.surface,
              ),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: movie.posterUrl?.isNotEmpty == true
                        ? CustomImageWidget(
                            imageUrl: movie.posterUrl!,
                            width: 35.w,
                            height: 20.h,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            width: 35.w,
                            height: 20.h,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.movie,
                              size: 50,
                              color: Colors.grey,
                            ),
                          ),
                  ),

                  // Rating Badge
                  Positioned(
                    top: 1.h,
                    right: 2.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 2.w,
                        vertical: 0.5.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CustomIconWidget(
                            iconName: 'star',
                            color: Colors.yellow,
                            size: 12,
                          ),
                          SizedBox(width: 1.w),
                          Text(
                            movie.rating.toStringAsFixed(1),
                            style: AppTheme.lightTheme.textTheme.bodySmall
                                ?.copyWith(
                              color: Colors.white,
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Play Overlay
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.black.withValues(alpha: 0.3),
                      ),
                      child: Center(
                        child: Container(
                          width: 12.w,
                          height: 12.w,
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(50),
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

            // Movie Title
            Text(
              movie.title,
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 0.5.h),

            // Year
            Text(
              movie.releaseYear.toString(),
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurface
                    .withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showQuickActionsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.lightTheme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
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
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 2.h),

            Text(
              movie.title,
              style: AppTheme.lightTheme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 3.h),

            // Quick Actions
            _buildQuickAction(
              context,
              "Phát",
              "play_arrow",
              () {
                Navigator.pop(context);
                // Handle play action
              },
            ),
            _buildQuickAction(
              context,
              "Thêm vào Danh sách xem",
              "add",
              () {
                Navigator.pop(context);
                // Handle watchlist action
              },
            ),
            _buildQuickAction(
              context,
              "Chia sẻ",
              "share",
              () {
                Navigator.pop(context);
                // Handle share action
              },
            ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAction(
    BuildContext context,
    String title,
    String iconName,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: CustomIconWidget(
        iconName: iconName,
        color: AppTheme.lightTheme.colorScheme.onSurface,
        size: 24,
      ),
      title: Text(
        title,
        style: AppTheme.lightTheme.textTheme.bodyMedium,
      ),
      onTap: onTap,
    );
  }
}
