import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class DescriptionSectionWidget extends StatefulWidget {
  final MovieModel movie;

  const DescriptionSectionWidget({
    super.key,
    required this.movie,
  });

  @override
  State<DescriptionSectionWidget> createState() =>
      _DescriptionSectionWidgetState();
}

class _DescriptionSectionWidgetState extends State<DescriptionSectionWidget> {
  bool _isExpanded = false;
  static const int _maxLines = 3;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Description
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedCrossFade(
                firstChild: Text(
                  widget.movie.description,
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurface,
                    height: 1.5,
                  ),
                  maxLines: _maxLines,
                  overflow: TextOverflow.ellipsis,
                ),
                secondChild: Text(
                  widget.movie.description,
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurface,
                    height: 1.5,
                  ),
                ),
                crossFadeState: _isExpanded
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 200),
              ),
              SizedBox(height: 1.h),

              // Read More/Less Button
              if (_shouldShowReadMore())
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isExpanded = !_isExpanded;
                    });
                  },
                  child: Text(
                    _isExpanded ? "Read Less" : "Read More",
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.lightTheme.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 3.h),

          // Movie Details
          _buildDetailRow("Đạo diễn", widget.movie.director),
          SizedBox(height: 1.h),
          _buildDetailRow("Thể loại", widget.movie.genres.join(", ")),
          SizedBox(height: 1.h),
          _buildDetailRow("Năm phát hành", widget.movie.releaseYear.toString()),
          SizedBox(height: 1.h),
          _buildDetailRow("Thời lượng", "${widget.movie.duration} phút"),
          SizedBox(height: 1.h),
          _buildDetailRow("Ngôn ngữ", widget.movie.language),
        ],
      ),
    );
  }

  bool _shouldShowReadMore() {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: widget.movie.description,
        style: AppTheme.lightTheme.textTheme.bodyMedium,
      ),
      maxLines: _maxLines,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(maxWidth: 92.w);
    return textPainter.didExceedMaxLines;
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 25.w,
          child: Text(
            label,
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurface
                  .withValues(alpha: 0.7),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: Text(
            value,
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}
