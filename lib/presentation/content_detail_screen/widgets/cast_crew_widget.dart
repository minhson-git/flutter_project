import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../models/movie_model.dart';

class CastCrewWidget extends StatelessWidget {
  final MovieModel movie;

  const CastCrewWidget({
    super.key,
    required this.movie,
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
              "Cast & Crew",
              style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(height: 2.h),

          // Cast List
          SizedBox(
            height: 20.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              itemCount: movie.cast.length,
              separatorBuilder: (context, index) => SizedBox(width: 3.w),
              itemBuilder: (context, index) {
                final castMember = movie.cast[index];
                return _CastMemberCard(castMember: castMember);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CastMemberCard extends StatelessWidget {
  final String castMember;

  const _CastMemberCard({required this.castMember});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 25.w,
      child: Column(
        children: [
          // Profile Image placeholder
          Container(
            width: 25.w,
            height: 25.w,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: AppTheme.lightTheme.colorScheme.surface,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Icon(
                Icons.person,
                size: 40,
                color: AppTheme.lightTheme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ),
          SizedBox(height: 1.h),

          // Actor Name
          Text(
            castMember,
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
