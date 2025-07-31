import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../core/app_export.dart';
import '../../../models/movie_model.dart';

class SearchResultsWidget extends StatelessWidget {
  final List<dynamic> results; // Can be MovieModel or Map
  final Function(dynamic) onResultTap;

  const SearchResultsWidget({
    super.key,
    required this.results,
    required this.onResultTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      itemCount: results.length,
      separatorBuilder: (context, index) => SizedBox(height: 2.h),
      itemBuilder: (context, index) {
        final result = results[index];
        return GestureDetector(
          onTap: () => onResultTap(result),
          child: Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.lightTheme.colorScheme.outline,
                width: 1,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: _buildThumbnail(result),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getTitle(result),
                        style:
                            AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 0.5.h),
                      Row(
                        children: [
                          Text(
                            _getYear(result),
                            style: AppTheme.lightTheme.textTheme.bodySmall
                                ?.copyWith(
                              color: AppTheme.lightTheme.colorScheme.onSurface
                                  .withValues(alpha: 0.7),
                            ),
                          ),
                          SizedBox(width: 2.w),
                          Container(
                            width: 1,
                            height: 12,
                            color: AppTheme.lightTheme.colorScheme.outline,
                          ),
                          SizedBox(width: 2.w),
                          CustomIconWidget(
                            iconName: 'star',
                            color: Colors.amber,
                            size: 14,
                          ),
                          SizedBox(width: 1.w),
                          Text(
                            _getRating(result),
                            style: AppTheme.lightTheme.textTheme.bodySmall
                                ?.copyWith(
                              color: AppTheme.lightTheme.colorScheme.onSurface
                                  .withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        _getDescription(result),
                        style:
                            AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.lightTheme.colorScheme.onSurface
                              .withValues(alpha: 0.8),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 1.h),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 2.w,
                          vertical: 0.5.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.lightTheme.colorScheme.primary
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          _getGenre(result),
                          style: AppTheme.lightTheme.textTheme.labelSmall
                              ?.copyWith(
                            color: AppTheme.lightTheme.colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                CustomIconWidget(
                  iconName: 'play_circle_outline',
                  color: AppTheme.lightTheme.colorScheme.primary,
                  size: 24,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildThumbnail(dynamic result) {
    String? imageUrl;

    if (result is MovieModel) {
      imageUrl = result.posterUrl;
    } else if (result is Map<String, dynamic>) {
      imageUrl = result['thumbnail'] as String?;
    }

    if (imageUrl?.isNotEmpty == true) {
      return CustomImageWidget(
        imageUrl: imageUrl!,
        width: 20.w,
        height: 12.h,
        fit: BoxFit.cover,
      );
    } else {
      return Container(
        width: 20.w,
        height: 12.h,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: Icon(
            Icons.movie,
            size: 30,
            color: Colors.grey,
          ),
        ),
      );
    }
  }

  String _getTitle(dynamic result) {
    if (result is MovieModel) {
      return result.title;
    } else if (result is Map<String, dynamic>) {
      return result['title'] as String;
    }
    return 'Unknown Title';
  }

  String _getYear(dynamic result) {
    if (result is MovieModel) {
      return result.releaseYear.toString();
    } else if (result is Map<String, dynamic>) {
      return result['year'] as String;
    }
    return 'Unknown';
  }

  String _getRating(dynamic result) {
    if (result is MovieModel) {
      return result.rating.toStringAsFixed(1);
    } else if (result is Map<String, dynamic>) {
      return result['rating'] as String;
    }
    return '0.0';
  }

  String _getDescription(dynamic result) {
    if (result is MovieModel) {
      return result.description;
    } else if (result is Map<String, dynamic>) {
      return result['description'] as String;
    }
    return 'No description available';
  }

  String _getGenre(dynamic result) {
    if (result is MovieModel) {
      return result.genres.isNotEmpty ? result.genres.join(', ') : 'Unknown';
    } else if (result is Map<String, dynamic>) {
      return result['genre'] as String;
    }
    return 'Unknown';
  }
}
