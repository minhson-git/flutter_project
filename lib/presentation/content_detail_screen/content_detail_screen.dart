import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_project/presentation/content_detail_screen/video_player/video_player_screen.dart';
import 'package:sizer/sizer.dart';
import 'package:video_player/video_player.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/app_export.dart';
import '../../models/movie_model.dart';
import '../../models/playlist_model.dart';
import '../../models/review_model.dart';
import '../../models/user_model.dart';
import '../../models/watch_history_model.dart';
import '../../services/auth_service.dart';
import '../../services/movie_service.dart';
import '../../services/playlist_service.dart';
import '../../services/review_service.dart';
import '../../services/user_service.dart';
import '../../services/watch_history_service.dart';
import './widgets/action_buttons_widget.dart';
import './widgets/cast_crew_widget.dart';
import './widgets/description_section_widget.dart';
import './widgets/hero_section_widget.dart';
import './widgets/more_like_this_widget.dart';
import './widgets/reviews_section_widget.dart';


class ContentDetailScreen extends StatefulWidget {
  final String? movieId;
  final MovieModel? movie;

  const ContentDetailScreen({super.key, this.movieId, this.movie});

  @override
  State<ContentDetailScreen> createState() => _ContentDetailScreenState();
}

class _ContentDetailScreenState extends State<ContentDetailScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _showStickyHeader = false;
  bool _isInWatchlist = false;
  bool _isLoading = true;
  bool _isFavorite = false;

  // Real data from Firebase
  MovieModel? _movie;
  UserModel? _currentUser;
  List<ReviewModel> _reviews = [];
  List<MovieModel> _relatedMovies = [];
  WatchHistoryModel? _watchHistory;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    // Delay loading until after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadMovieData();
    });
  }

  void _loadMovieData() async {
    setState(() => _isLoading = true);

    print('🎬 Loading movie data...');
    print('Widget.movie: ${widget.movie?.title}');
    print('Widget.movieId: ${widget.movieId}');

    try {
      // Priority: widget.movie > navigation arguments > load by ID
      if (widget.movie != null) {
        _movie = widget.movie;
        print('✅ Using widget.movie: ${_movie!.title}');
      } else {
        final args = ModalRoute.of(context)?.settings.arguments;
        if (args is MovieModel) {
          _movie = args;
          print('✅ Using navigation args: ${_movie!.title}');
        } else if (widget.movieId != null) {
          // Load movie by ID
          _movie = await MovieService.getMovieById(widget.movieId!);
          print('✅ Loaded by ID: ${_movie?.title}');
        }
      }

      if (_movie == null) {
        print('❌ Movie is null');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Không tìm thấy thông tin phim')),
          );
          Navigator.pop(context);
        }
        return;
      }

      print('🎬 Movie loaded: ${_movie!.title} (ID: ${_movie!.id})');

      // Load current user
      final currentUserId = AuthService.currentUser?.uid;
      if (currentUserId != null && _movie!.id != null) {
        try {
          _currentUser = await UserService.getUserProfile(currentUserId);

          // Check if movie is in user's favorites
          _isFavorite = _currentUser?.favoriteMovies.contains(_movie!.id) ?? false;

          // Load user's watch history for this movie
          final watchHistoryList = await WatchHistoryService.getUserWatchHistory(currentUserId);
          _watchHistory = watchHistoryList.firstWhere(
                (history) => history.movieId == _movie!.id,
            orElse: () => WatchHistoryModel(
              userId: currentUserId,
              movieId: _movie!.id!,
              totalDuration: _movie!.duration * 60, // convert minutes to seconds
              watchedAt: DateTime.now(),
              lastWatchedAt: DateTime.now(),
            ),
          );
        } catch (e) {
          print('⚠️ Error loading user data: $e');
          // Continue without user data
        }
      }

      // Load reviews for this movie (only if movie has ID)
      if (_movie!.id != null) {
        try {
          _reviews = await ReviewService.getMovieReviews(_movie!.id!);
        } catch (e) {
          print('⚠️ Error loading reviews: $e');
          _reviews = [];
        }
      }

      // Load related movies (same genre)
      if (_movie!.genres.isNotEmpty) {
        try {
          final allMovies = await MovieService.getAllMovies();
          _relatedMovies = allMovies
              .where((movie) =>
          movie.id != _movie!.id &&
              movie.genres.any((genre) => _movie!.genres.contains(genre)))
              .take(10)
              .toList();
        } catch (e) {
          print('⚠️ Error loading related movies: $e');
          _relatedMovies = [];
        }
      }

      print('✅ Loaded movie data: ${_movie!.title}, ${_reviews.length} reviews, ${_relatedMovies.length} related');
    } catch (e) {
      print('❌ Error loading movie data: $e');
      if (mounted) {
        // Don't pop if we have basic movie data
        if (_movie != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Một số dữ liệu không tải được: $e')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Lỗi tải dữ liệu: $e')),
          );
          Navigator.pop(context);
          return;
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.offset > 200 && !_showStickyHeader) {
      setState(() {
        _showStickyHeader = true;
      });
    } else if (_scrollController.offset <= 200 && _showStickyHeader) {
      setState(() {
        _showStickyHeader = false;
      });
    }
  }

  void _onPlayPressed() {
    if (_movie == null) return;

    // Update watch history
    _updateWatchHistory();

    // Check if we have trailer URL
    if (_movie!.trailerUrl != null && _movie!.trailerUrl!.isNotEmpty) {
      // Navigate to video player screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VideoPlayerScreen(
            title: '${_movie!.title} - Trailer',
            videoUrl: _movie!.trailerUrl!,
          ),
        ),
      );
    } else {
      // Show message that no trailer is available
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Trailer cho "${_movie!.title}" hiện chưa có sẵn'),
          backgroundColor: const Color(0xFF1A1A1A),
          action: SnackBarAction(
            label: 'OK',
            textColor: const Color(0xFFE50914),
            onPressed: () {},
          ),
        ),
      );
    }
  }

  Future<void> _updateWatchHistory() async {
    if (_currentUser == null || _movie == null) return;

    try {
      final history = WatchHistoryModel(
        userId: _currentUser!.id!,
        movieId: _movie!.id!,
        watchDuration: _watchHistory?.watchDuration ?? 0,
        totalDuration: _movie!.duration * 60, // convert minutes to seconds
        watchedAt: _watchHistory?.watchedAt ?? DateTime.now(),
        lastWatchedAt: DateTime.now(),
      );

      await WatchHistoryService.addOrUpdateWatchHistory(history);
    } catch (e) {
      print('Error updating watch history: $e');
    }
  }

  void _onWatchlistPressed() async {
    if (_currentUser == null || _movie == null) return;

    try {
      if (_isFavorite) {
        await UserService.removeFromFavorites(_currentUser!.id!, _movie!.id!);
        setState(() => _isFavorite = false);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Đã xóa "${_movie!.title}" khỏi danh sách yêu thích'),
              action: SnackBarAction(
                label: 'Hoàn tác',
                onPressed: () => _addToFavorites(),
              ),
            ),
          );
        }
      } else {
        await _addToFavorites();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _addToFavorites() async {
    if (_currentUser == null || _movie == null) return;

    try {
      await UserService.addToFavorites(_currentUser!.id!, _movie!.id!);
      setState(() => _isFavorite = true);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã thêm "${_movie!.title}" vào danh sách yêu thích'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('Error adding to favorites: $e');
    }
  }

  void _onSharePressed() {
    if (_movie == null) return;

    // Show share options
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.lightTheme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => _ShareBottomSheet(
        title: _movie!.title,
        movie: _movie!,
      ),
    );
  }

  void _onMyListPressed() async {
    if (_movie == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không tìm thấy thông tin phim')),
      );
      return;
    }

    try {
      final currentUserId = AuthService.currentUser?.uid;
      if (currentUserId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vui lòng đăng nhập để sử dụng tính năng này')),
        );
        return;
      }

      // Load user playlists
      final playlists = await PlaylistService.getUserPlaylists(currentUserId);

      if (!mounted) return;

      showModalBottomSheet(
        context: context,
        backgroundColor: const Color(0xFF1A1A1A),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        isScrollControlled: true,
        builder: (context) => Container(
          padding: EdgeInsets.all(4.w),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.7,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 12.w,
                height: 0.5.h,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(height: 2.h),

              // Title
              Text(
                'Thêm "${_movie!.title}" vào playlist',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 3.h),

              // Create new playlist option
              ListTile(
                leading: Container(
                  padding: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE50914),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 20),
                ),
                title: const Text(
                  'Tạo playlist mới',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _showCreatePlaylistDialog();
                },
              ),

              if (playlists.isNotEmpty) ...[
                Divider(color: Colors.white.withValues(alpha: 0.2)),
                SizedBox(height: 1.h),

                // Existing playlists
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: playlists.length,
                    itemBuilder: (context, index) {
                      final playlist = playlists[index];
                      return ListTile(
                        leading: Container(
                          padding: EdgeInsets.all(2.w),
                          decoration: BoxDecoration(
                            color: playlist.isDefault
                                ? Colors.orange
                                : const Color(0xFF4ECDC4),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            playlist.isDefault
                                ? Icons.star
                                : playlist.isPublic
                                ? Icons.public
                                : Icons.playlist_play,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        title: Text(
                          playlist.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(
                          '${playlist.movieCount} phim',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                          ),
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          _addMovieToPlaylist(playlist);
                        },
                      );
                    },
                  ),
                ),
              ] else ...[
                SizedBox(height: 2.h),
                Container(
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A2A2A),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.playlist_add,
                        size: 48,
                        color: Colors.white.withValues(alpha: 0.5),
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        'Chưa có playlist nào',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 16.sp,
                        ),
                      ),
                      SizedBox(height: 1.h),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _showCreatePlaylistDialog();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE50914),
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Tạo playlist đầu tiên'),
                      ),
                    ],
                  ),
                ),
              ],

              SizedBox(height: 2.h),
            ],
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi tải playlist: $e')),
        );
      }
    }
  }

  void _showCreatePlaylistDialog() {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    bool isPublic = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: const Color(0xFF1A1A1A),
          title: const Text(
            'Tạo playlist mới',
            style: TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Tên playlist *',
                  labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
                  hintText: 'Nhập tên playlist',
                  hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFE50914)),
                  ),
                ),
              ),
              SizedBox(height: 2.h),
              TextField(
                controller: descriptionController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Mô tả',
                  labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
                  hintText: 'Mô tả ngắn về playlist (tùy chọn)',
                  hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFE50914)),
                  ),
                ),
                maxLines: 2,
              ),
              CheckboxListTile(
                title: const Text(
                  'Công khai',
                  style: TextStyle(color: Colors.white),
                ),
                subtitle: Text(
                  'Cho phép người khác xem playlist này',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
                ),
                value: isPublic,
                activeColor: const Color(0xFFE50914),
                onChanged: (value) {
                  setState(() {
                    isPublic = value ?? false;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Hủy',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Vui lòng nhập tên playlist')),
                  );
                  return;
                }
                Navigator.pop(context);
                await _createPlaylistAndAddMovie(
                  nameController.text.trim(),
                  descriptionController.text.trim(),
                  isPublic,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE50914),
                foregroundColor: Colors.white,
              ),
              child: const Text('Tạo & Thêm phim'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createPlaylistAndAddMovie(
      String name,
      String description,
      bool isPublic,
      ) async {
    try {
      final currentUserId = AuthService.currentUser?.uid;
      if (currentUserId == null || _movie == null) return;

      // Create playlist
      final playlist = PlaylistModel(
        userId: currentUserId,
        name: name,
        description: description,
        isPublic: isPublic,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final createdPlaylist = await PlaylistService.createPlaylist(playlist);

      // Add movie to playlist
      if (_movie!.id != null) {
        await PlaylistService.addMovieToPlaylist(createdPlaylist, _movie!.id!);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Đã tạo playlist "$name" và thêm "${_movie!.title}"'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi tạo playlist: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _addMovieToPlaylist(PlaylistModel playlist) async {
    try {
      if (_movie?.id == null || playlist.id == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lỗi: Thông tin phim hoặc playlist không hợp lệ')),
        );
        return;
      }

      await PlaylistService.addMovieToPlaylist(playlist.id!, _movie!.id!);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã thêm "${_movie!.title}" vào "${playlist.name}"'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi thêm vào playlist: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _onBackPressed() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_movie == null) {
      return Scaffold(
        backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
        appBar: AppBar(
          title: const Text('Chi tiết phim'),
          backgroundColor: AppTheme.lightTheme.primaryColor,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Text('Không tìm thấy thông tin phim'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              // Hero Section
              SliverToBoxAdapter(
                child: HeroSectionWidget(
                  movie: _movie!,
                  onBackPressed: _onBackPressed,
                ),
              ),

              // Action Buttons
              SliverToBoxAdapter(
                child: ActionButtonsWidget(
                  isInWatchlist: _isFavorite,
                  onPlayPressed: _onPlayPressed,
                  onWatchlistPressed: _onWatchlistPressed,
                  onSharePressed: _onSharePressed,
                  onMyListPressed: _onMyListPressed,
                  watchHistory: _watchHistory,
                ),
              ),

              // Description Section
              SliverToBoxAdapter(
                child: DescriptionSectionWidget(
                  movie: _movie!,
                ),
              ),

              // Cast & Crew (if available)
              if (_movie!.cast.isNotEmpty)
                SliverToBoxAdapter(
                  child: CastCrewWidget(
                    movie: _movie!,
                  ),
                ),

              // More Like This
              if (_relatedMovies.isNotEmpty)
                SliverToBoxAdapter(
                  child: MoreLikeThisWidget(
                    relatedMovies: _relatedMovies,
                  ),
                ),

              // Reviews Section
              SliverToBoxAdapter(
                child: ReviewsSectionWidget(
                  reviews: _reviews,
                  averageRating: _calculateAverageRating(),
                  movie: _movie!,
                  currentUser: _currentUser,
                  onReviewAdded: _onReviewAdded,
                ),
              ),

              // Bottom spacing
              SliverToBoxAdapter(
                child: SizedBox(height: 4.h),
              ),
            ],
          ),

          // Sticky Header
          if (_showStickyHeader)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 12.h,
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.scaffoldBackgroundColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: _onBackPressed,
                          child: Container(
                            width: 10.w,
                            height: 10.w,
                            decoration: BoxDecoration(
                              color: AppTheme.lightTheme.colorScheme.surface,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: CustomIconWidget(
                              iconName: 'arrow_back',
                              color: AppTheme.lightTheme.colorScheme.onSurface,
                              size: 20,
                            ),
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Expanded(
                          child: Text(
                            _movie!.title,
                            style: AppTheme.lightTheme.textTheme.titleLarge,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  double _calculateAverageRating() {
    if (_reviews.isEmpty) return 0.0;
    double totalRating = _reviews.fold(0.0, (sum, review) => sum + review.rating);
    return totalRating / _reviews.length;
  }

  void _onReviewAdded(ReviewModel review) async {
    try {
      print('Saving review to Firebase...');
      print('Review data: userId=${review.userId}, movieId=${review.movieId}, rating=${review.rating}');

      // Save review to Firebase
      String reviewId = await ReviewService.addReview(review);

      // Create review with Firebase ID
      final reviewWithId = ReviewModel(
        id: reviewId,
        userId: review.userId,
        movieId: review.movieId,
        rating: review.rating,
        comment: review.comment,
        createdAt: review.createdAt,
        updatedAt: review.updatedAt,
      );

      // Update UI
      setState(() {
        _reviews.insert(0, reviewWithId);
      });

      print('Review added successfully: $reviewId');
    } catch (e) {
      print('Error adding review: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi lưu đánh giá: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

// Video Player Screen
class _VideoPlayerScreen extends StatefulWidget {
  final String title;
  final String videoUrl;
  final MovieModel movie;

  const _VideoPlayerScreen({
    required this.title,
    required this.videoUrl,
    required this.movie,
  });

  @override
  State<_VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<_VideoPlayerScreen> {
  bool _showControls = true;
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _isPlaying = false;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Set landscape orientation for video playback
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      print('🎥 Initializing video: ${widget.videoUrl}');

      // Check if URL is valid
      if (widget.videoUrl.isEmpty || widget.videoUrl == "sample_video_url") {
        setState(() {
          _errorMessage = "URL video không hợp lệ";
          _isLoading = false;
        });
        return;
      }

      _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));

      await _controller!.initialize();

      setState(() {
        _isInitialized = true;
        _isLoading = false;
      });

      // Auto-hide controls after 3 seconds
      _autoHideControls();

      print('Video initialized successfully');
    } catch (e) {
      print('Error initializing video: $e');
      setState(() {
        _errorMessage = "Không thể tải video: $e";
        _isLoading = false;
      });
    }
  }

  void _autoHideControls() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && _showControls) {
        setState(() {
          _showControls = false;
        });
      }
    });
  }

  void _togglePlayPause() {
    if (_controller == null || !_isInitialized) return;

    setState(() {
      if (_controller!.value.isPlaying) {
        _controller!.pause();
        _isPlaying = false;
      } else {
        _controller!.play();
        _isPlaying = true;
        _autoHideControls();
      }
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  void dispose() {
    _controller?.dispose();
    // Reset orientation when leaving video player
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () {
          setState(() {
            _showControls = !_showControls;
          });
          if (_showControls) {
            _autoHideControls();
          }
        },
        child: Stack(
          children: [
            // Video player or error/loading state
            Center(
              child: _isLoading
                  ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE50914)),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'Đang tải video...',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.sp,
                    ),
                  ),
                ],
              )
                  : _errorMessage != null
                  ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 64,
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    _errorMessage!,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.sp,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 2.h),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE50914),
                    ),
                    child: const Text(
                      'Quay lại',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              )
                  : _isInitialized
                  ? AspectRatio(
                aspectRatio: _controller!.value.aspectRatio,
                child: VideoPlayer(_controller!),
              )
                  : Container(
                color: Colors.black,
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ),

            // Video controls overlay
            if (_showControls && _isInitialized && _errorMessage == null)
              Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.7),
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.7),
                    ],
                  ),
                ),
                child: Column(
                  children: [
                    // Top controls
                    SafeArea(
                      child: Padding(
                        padding: EdgeInsets.all(2.w),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Container(
                                padding: EdgeInsets.all(2.w),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.5),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.arrow_back,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                            ),
                            SizedBox(width: 4.w),
                            Expanded(
                              child: Text(
                                widget.title,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const Spacer(),

                    // Center play/pause button
                    GestureDetector(
                      onTap: _togglePlayPause,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(40),
                        ),
                        child: Icon(
                          _isPlaying ? Icons.pause : Icons.play_arrow,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                    ),

                    const Spacer(),

                    // Bottom controls
                    Padding(
                      padding: EdgeInsets.all(2.w),
                      child: Column(
                        children: [
                          // Progress bar
                          VideoProgressIndicator(
                            _controller!,
                            allowScrubbing: true,
                            colors: VideoProgressColors(
                              playedColor: const Color(0xFFE50914),
                              bufferedColor: Colors.white.withValues(alpha: 0.3),
                              backgroundColor: Colors.white.withValues(alpha: 0.1),
                            ),
                          ),
                          SizedBox(height: 1.h),
                          // Time and controls
                          Row(
                            children: [
                              Text(
                                _formatDuration(_controller!.value.position),
                                style: const TextStyle(color: Colors.white),
                              ),
                              const Spacer(),
                              Text(
                                _formatDuration(_controller!.value.duration),
                                style: const TextStyle(color: Colors.white),
                              ),
                              SizedBox(width: 4.w),
                              GestureDetector(
                                onTap: () {
                                  // Toggle fullscreen (already in fullscreen)
                                },
                                child: const Icon(
                                  Icons.fullscreen,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// Share Bottom Sheet
class _ShareBottomSheet extends StatelessWidget {
  final String title;
  final MovieModel movie;

  const _ShareBottomSheet({
    required this.title,
    required this.movie,
  });

  @override
  Widget build(BuildContext context) {
    final shareOptions = [
      {"name": "Copy Link", "icon": "link"},
      {"name": "WhatsApp", "icon": "share"},
      {"name": "Twitter", "icon": "share"},
      {"name": "Facebook", "icon": "share"},
      {"name": "Instagram", "icon": "share"},
      {"name": "More", "icon": "more_horiz"},
    ];

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
            "Share \"$title\"",
            style: AppTheme.lightTheme.textTheme.titleMedium,
          ),
          SizedBox(height: 3.h),

          // Share options grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 1,
              crossAxisSpacing: 2.w,
              mainAxisSpacing: 2.h,
            ),
            itemCount: shareOptions.length,
            itemBuilder: (context, index) {
              final option = shareOptions[index];
              return GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  // Handle share action
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 12.w,
                      height: 12.w,
                      decoration: BoxDecoration(
                        color: AppTheme.lightTheme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: CustomIconWidget(
                        iconName: option["icon"] as String,
                        color: AppTheme.lightTheme.colorScheme.onSurface,
                        size: 24,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      option["name"] as String,
                      style: AppTheme.lightTheme.textTheme.bodySmall,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            },
          ),
          SizedBox(height: 2.h),
        ],
      ),
    );
  }
}
