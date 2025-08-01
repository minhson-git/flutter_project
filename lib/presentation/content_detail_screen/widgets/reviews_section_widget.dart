import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../models/movie_model.dart';
import '../../../models/review_model.dart';
import '../../../models/user_model.dart';

class ReviewsSectionWidget extends StatefulWidget {
  final List<ReviewModel> reviews;
  final double averageRating;
  final MovieModel movie;
  final UserModel? currentUser;
  final void Function(ReviewModel review) onReviewAdded;

  const ReviewsSectionWidget({
    super.key,
    required this.reviews,
    required this.averageRating,
    required this.movie,
    required this.currentUser,
    required this.onReviewAdded,
  });

  @override
  State<ReviewsSectionWidget> createState() => _ReviewsSectionWidgetState();
}

class _ReviewsSectionWidgetState extends State<ReviewsSectionWidget> {
  bool _showAllReviews = false;

  @override
  Widget build(BuildContext context) {
    final displayReviews =
        _showAllReviews ? widget.reviews : widget.reviews.take(2).toList();

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Reviews & Comments",
                style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
              GestureDetector(
                onTap: _showWriteReviewModal,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 3.w,
                    vertical: 1.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.primaryColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    "Write a review",
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),

          // Average Rating Display
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                // Rating Score
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.averageRating.toStringAsFixed(1),
                      style: AppTheme.lightTheme.textTheme.headlineMedium
                          ?.copyWith(
                        color: AppTheme.lightTheme.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: List.generate(5, (index) {
                        return CustomIconWidget(
                          iconName: index < widget.averageRating.floor()
                              ? 'star'
                              : 'star_border',
                          color: Colors.yellow,
                          size: 16,
                        );
                      }),
                    ),
                  ],
                ),
                SizedBox(width: 4.w),

                // Review Count
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${widget.reviews.length} review",
                        style:
                            AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                          color: AppTheme.lightTheme.colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        "Based on user reviews",
                        style:
                            AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.lightTheme.colorScheme.onSurface
                              .withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 2.h),

          // Reviews List
          ...displayReviews.map((review) => _ReviewCard(review: review)),

          // Show More/Less Button
          if (widget.reviews.length > 2)
            Center(
              child: TextButton(
                onPressed: () {
                  setState(() {
                    _showAllReviews = !_showAllReviews;
                  });
                },
                child: Text(
                  _showAllReviews ? "Hide" : "View all reviews",
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.lightTheme.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showWriteReviewModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.lightTheme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: _WriteReviewModal(
          movie: widget.movie,
          currentUser: widget.currentUser,
          onReviewAdded: widget.onReviewAdded,
        ),
      ),
    );
  }
}

class _ReviewCard extends StatefulWidget {
  final ReviewModel review;

  const _ReviewCard({required this.review});

  @override
  State<_ReviewCard> createState() => _ReviewCardState();
}

class _ReviewCardState extends State<_ReviewCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User Info and Rating
          Row(
            children: [
              // User Avatar
              Container(
                width: 10.w,
                height: 10.w,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  color: AppTheme.lightTheme.colorScheme.surfaceContainer,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(25),
                  child: Icon(
                    Icons.person,
                    size: 20,
                    color: Colors.grey[600],
                  ),
                ),
              ),
              SizedBox(width: 3.w),

              // User Name and Date
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "User ${widget.review.userId.length >= 8 ? widget.review.userId.substring(0, 8) : widget.review.userId}", // Temporary placeholder
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      "${widget.review.createdAt.day}/${widget.review.createdAt.month}/${widget.review.createdAt.year}",
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurface
                            .withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),

              // Rating Stars
              Row(
                children: List.generate(5, (index) {
                  final rating = widget.review.rating;
                  return CustomIconWidget(
                    iconName: index < rating.floor() ? 'star' : 'star_border',
                    color: Colors.yellow,
                    size: 16,
                  );
                }),
              ),
            ],
          ),
          SizedBox(height: 1.h),

          // Review Text
          AnimatedCrossFade(
            firstChild: Text(
              widget.review.comment,
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurface,
                height: 1.4,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            secondChild: Text(
              widget.review.comment,
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurface,
                height: 1.4,
              ),
            ),
            crossFadeState: _isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),

          // Read More Button
          if (_shouldShowReadMore())
            GestureDetector(
              onTap: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
              child: Padding(
                padding: EdgeInsets.only(top: 1.h),
                child: Text(
                  _isExpanded ? "Collapse" : "See more",
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.lightTheme.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  bool _shouldShowReadMore() {
    final reviewText = widget.review.comment;
    return reviewText.length > 150; // Simple length check
  }
}

class _WriteReviewModal extends StatefulWidget {
  final MovieModel movie;
  final UserModel? currentUser;
  final void Function(ReviewModel review) onReviewAdded;

  const _WriteReviewModal({
    required this.movie,
    required this.currentUser,
    required this.onReviewAdded,
  });

  @override
  State<_WriteReviewModal> createState() => _WriteReviewModalState();
}

class _WriteReviewModalState extends State<_WriteReviewModal> {
  final TextEditingController _reviewController = TextEditingController();
  double _rating = 0;

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
            "Write a review",
            style: AppTheme.lightTheme.textTheme.titleLarge,
          ),
          SizedBox(height: 3.h),

          // Rating Selection
          Text(
            "Rate this movie",
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 1.h),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _rating = index + 1.0;
                  });
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 1.w),
                  child: CustomIconWidget(
                    iconName: index < _rating ? 'star' : 'star_border',
                    color: Colors.yellow,
                    size: 32,
                  ),
                ),
              );
            }),
          ),
          SizedBox(height: 3.h),

          // Review Text Field
          TextField(
            controller: _reviewController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: "Share your thoughts about this movie...",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          SizedBox(height: 3.h),

          // Submit Button
          SizedBox(
            width: double.infinity,
            height: 6.h,
            child: ElevatedButton(
              onPressed: _rating > 0 && _reviewController.text.isNotEmpty
                  ? () async {
                      if (widget.currentUser == null) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("You need to log in to write a review"),
                          ),
                        );
                        return;
                      }

                      // Show loading
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) => const Center(
                          child: CircularProgressIndicator(),
                        ),
                      );

                      try {
                        print('🔄 Creating review...');
                        print('Movie ID: ${widget.movie.id}');
                        print('User ID: ${widget.currentUser!.id}');
                        print('Rating: $_rating');
                        print('Comment: ${_reviewController.text.trim()}');

                        // Create new review
                        final newReview = ReviewModel(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          movieId: widget.movie.id ?? '',
                          userId: widget.currentUser!.id ?? '',
                          rating: _rating,
                          comment: _reviewController.text.trim(),
                          createdAt: DateTime.now(),
                          updatedAt: DateTime.now(),
                        );

                        print('📝 Review created, calling onReviewAdded...');

                        // Close loading dialog
                        if (Navigator.canPop(context)) {
                          Navigator.pop(context);
                        }

                        // Close review modal
                        Navigator.pop(context);

                        // Reset form
                        _reviewController.clear();
                        _rating = 0;

                        // Add review through callback
                        widget.onReviewAdded(newReview);

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Review submitted successfully!"),
                            backgroundColor: Colors.green,
                          ),
                        );
                      } catch (e) {
                        // Close loading dialog
                        if (Navigator.canPop(context)) {
                          Navigator.pop(context);
                        }

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Error: $e"),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  : null,
              child: Text(
                "Submit review",
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          SizedBox(height: 2.h),
        ],
      ),
    );
  }
}
