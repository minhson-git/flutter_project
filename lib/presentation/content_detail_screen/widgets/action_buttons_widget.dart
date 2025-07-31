import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../models/watch_history_model.dart';

class ActionButtonsWidget extends StatelessWidget {
  final bool isInWatchlist;
  final VoidCallback onPlayPressed;
  final VoidCallback onWatchlistPressed;
  final VoidCallback onSharePressed;
  final WatchHistoryModel? watchHistory;

  const ActionButtonsWidget({
    super.key,
    required this.isInWatchlist,
    required this.onPlayPressed,
    required this.onWatchlistPressed,
    required this.onSharePressed,
    this.watchHistory,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.w),
      child: Column(
        children: [
          // Primary Play Button
          SizedBox(
            width: double.infinity,
            height: 6.h,
            child: ElevatedButton.icon(
              onPressed: onPlayPressed,
              label: Text(
                _getPlayButtonText(),
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.lightTheme.primaryColor,
                foregroundColor: Colors.white,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          SizedBox(height: 2.h),

          // Secondary Action Buttons
          Row(
            children: [
              // Add to Watchlist Button
              Expanded(
                child: SizedBox(
                  height: 5.h,
                  child: OutlinedButton.icon(
                    onPressed: onWatchlistPressed,
                    icon: CustomIconWidget(
                      iconName: isInWatchlist ? 'check' : 'add',
                      color: AppTheme.lightTheme.colorScheme.onSurface,
                      size: 20,
                    ),
                    label: Text(
                      isInWatchlist ? "Yêu thích" : "Yêu thích",
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurface,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: AppTheme.lightTheme.colorScheme.outline,
                        width: 1,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 3.w),

              // Share Button
              Expanded(
                child: SizedBox(
                  height: 5.h,
                  child: OutlinedButton.icon(
                    onPressed: onSharePressed,
                    icon: CustomIconWidget(
                      iconName: 'share',
                      color: AppTheme.lightTheme.colorScheme.onSurface,
                      size: 20,
                    ),
                    label: Text(
                      "Share",
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurface,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: AppTheme.lightTheme.colorScheme.outline,
                        width: 1,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
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

  String _getPlayButtonText() {
    if (watchHistory == null || watchHistory!.watchDuration == 0) {
      return "▶️ Phát";
    } else if (watchHistory!.isCompleted) {
      return "🔄 Xem lại";
    } else {
      final progress = watchHistory!.progressPercentage.round();
      return "▶️ Tiếp tục ($progress%)";
    }
  }
}
