import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

enum EmptyStateType {
  noQuery,
  noResults,
  networkError,
}

class EmptyStateWidget extends StatelessWidget {
  final EmptyStateType type;

  const EmptyStateWidget({
    super.key,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    String title;
    String description;
    String iconName;
    String? buttonText;
    VoidCallback? onButtonPressed;

    switch (type) {
      case EmptyStateType.noQuery:
        title = 'Start Your Search';
        description =
        'Enter a movie title, actor name, or genre to discover amazing content';
        iconName = 'search';
        break;
      case EmptyStateType.noResults:
        title = 'No Results Found';
        description =
        'Try adjusting your search terms or filters to find what you\'re looking for';
        iconName = 'search_off';
        buttonText = 'Clear Filters';
        onButtonPressed = () {
          // Clear filters logic would go here
        };
        break;
      case EmptyStateType.networkError:
        title = 'Connection Error';
        description = 'Please check your internet connection and try again';
        iconName = 'wifi_off';
        buttonText = 'Retry';
        onButtonPressed = () {
          // Retry logic would go here
        };
        break;
    }

    return Center(
      child: Padding(
        padding: EdgeInsets.all(8.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 20.w,
              height: 20.w,
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.surface,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppTheme.lightTheme.colorScheme.outline,
                  width: 1,
                ),
              ),
              child: Center(
                child: CustomIconWidget(
                  iconName: iconName,
                  color: AppTheme.lightTheme.colorScheme.onSurface
                      .withValues(alpha: 0.6),
                  size: 8.w,
                ),
              ),
            ),
            SizedBox(height: 3.h),
            Text(
              title,
              style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 1.h),
            Text(
              description,
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurface
                    .withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            if (buttonText != null && onButtonPressed != null) ...[
              SizedBox(height: 3.h),
              ElevatedButton(
                onPressed: onButtonPressed,
                child: Text(buttonText),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
