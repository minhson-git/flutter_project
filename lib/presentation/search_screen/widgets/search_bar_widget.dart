import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class SearchBarWidget extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final Function(String) onSubmitted;
  final VoidCallback onVoiceSearch;
  final VoidCallback onBarcodeSearch;
  final bool isVoiceSearching;

  const SearchBarWidget({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onSubmitted,
    required this.onVoiceSearch,
    required this.onBarcodeSearch,
    required this.isVoiceSearching,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              onSubmitted: onSubmitted,
              style: AppTheme.lightTheme.textTheme.bodyLarge,
              decoration: InputDecoration(
                hintText: 'Search movies, shows, actors...',
                hintStyle: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurface
                      .withValues(alpha: 0.6),
                ),
                prefixIcon: Padding(
                  padding: EdgeInsets.all(3.w),
                  child: CustomIconWidget(
                    iconName: 'search',
                    color: AppTheme.lightTheme.colorScheme.onSurface
                        .withValues(alpha: 0.6),
                    size: 20,
                  ),
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 4.w,
                  vertical: 3.w,
                ),
              ),
            ),
          ),
          if (controller.text.isNotEmpty)
            IconButton(
              onPressed: () {
                controller.clear();
                focusNode.requestFocus();
              },
              icon: CustomIconWidget(
                iconName: 'clear',
                color: AppTheme.lightTheme.colorScheme.onSurface
                    .withValues(alpha: 0.6),
                size: 20,
              ),
            ),
          Container(
            height: 6.h,
            width: 1,
            color: AppTheme.lightTheme.colorScheme.outline,
          ),
          IconButton(
            onPressed: onVoiceSearch,
            icon: isVoiceSearching
                ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppTheme.lightTheme.colorScheme.primary,
                ),
              ),
            )
                : CustomIconWidget(
              iconName: 'mic',
              color: isVoiceSearching
                  ? AppTheme.lightTheme.colorScheme.primary
                  : AppTheme.lightTheme.colorScheme.onSurface
                  .withValues(alpha: 0.6),
              size: 20,
            ),
          ),
          IconButton(
            onPressed: onBarcodeSearch,
            icon: CustomIconWidget(
              iconName: 'qr_code_scanner',
              color: AppTheme.lightTheme.colorScheme.onSurface
                  .withValues(alpha: 0.6),
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}
