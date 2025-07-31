import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../models/category_model.dart';
import '../../models/movie_model.dart';
import '../../models/user_model.dart';
import '../../models/watch_history_model.dart';
import '../../services/auth_service.dart';
import '../../services/category_service.dart';
import '../../services/movie_service.dart';
import '../../services/user_service.dart';
import './widgets/content_carousel_widget.dart';
import './widgets/hero_banner_widget.dart';
import './widgets/home_header_widget.dart';
import '../../services/watch_history_service.dart';
import '../../widgets/custom_image_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late ScrollController _scrollController;
  int _currentBottomNavIndex = 0;
  bool _isRefreshing = false;
  bool _isLoading = true;

  // Firebase data
  List<MovieModel> _featuredMovies = [];
  List<MovieModel> _continueWatchingMovies = [];
  List<MovieModel> _trendingMovies = [];
  List<MovieModel> _newReleaseMovies = [];
  List<MovieModel> _actionMovies = [];
  List<CategoryModel> _categories = [];
  UserModel? _currentUser;
  
  // Store watch history data to use in conversion
  List<WatchHistoryModel> _watchHistoryData = [];

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _loadFirebaseData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    setState(() {
      _isRefreshing = true;
    });

    await _loadFirebaseData();

    setState(() {
      _isRefreshing = false;
    });
  }

  Future<void> _loadFirebaseData() async {
    setState(() => _isLoading = true);

    try {
      // Load current user
      final currentUserId = AuthService.currentUser?.uid;
      if (currentUserId != null) {
        _currentUser = await UserService.getUserProfile(currentUserId);
      }

      // Load different sections
      await Future.wait([
        _loadFeaturedMovies(),
        _loadContinueWatching(),
        _loadTrendingMovies(),
        _loadNewReleases(),
        _loadActionMovies(),
        _loadCategories(),
      ]);

      print('✅ Loaded Firebase data successfully');
    } catch (e) {
      print('❌ Error loading Firebase data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi tải dữ liệu: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadFeaturedMovies() async {
    _featuredMovies = await MovieService.getFeaturedMovies();
    print('🎬 Loaded ${_featuredMovies.length} featured movies');
  }

  Future<void> _loadContinueWatching() async {
    final currentUserId = AuthService.currentUser?.uid;
    print('🔍 Loading continue watching for user: $currentUserId');
    
    if (currentUserId != null) {
      try {
        _watchHistoryData = await WatchHistoryService.getUserWatchHistory(currentUserId);
        print('📺 Found ${_watchHistoryData.length} watch history items');
        
        if (_watchHistoryData.isNotEmpty) {
          final movieIds = _watchHistoryData.map((h) => h.movieId).toList();
          print('🎬 Movie IDs to load: $movieIds');
          
          _continueWatchingMovies = await MovieService.getMoviesByIds(movieIds);
          print('✅ Loaded ${_continueWatchingMovies.length} continue watching movies');
        } else {
          print('⚠️ No watch history found for user');
          _continueWatchingMovies = [];
        }
      } catch (e) {
        print('❌ Error loading continue watching: $e');
        _continueWatchingMovies = [];
        _watchHistoryData = [];
      }
    } else {
      print('⚠️ No current user found');
      _continueWatchingMovies = [];
      _watchHistoryData = [];
    }
  }

  Future<void> _loadTrendingMovies() async {
    _trendingMovies = await MovieService.getPopularMovies();
    print('📈 Loaded ${_trendingMovies.length} trending movies');
  }

  Future<void> _loadNewReleases() async {
    _newReleaseMovies = await MovieService.getLatestMovies(limit: 10);
  }

  Future<void> _loadActionMovies() async {
    _actionMovies = await MovieService.getMoviesByGenre('Action');
  }

  Future<void> _loadCategories() async {
    _categories = await CategoryService.getAllCategories();
  }

  void _onBottomNavTap(int index) {
    setState(() {
      _currentBottomNavIndex = index;
    });

    switch (index) {
      case 0:
      // Already on home
        break;
      case 1:
        _navigateToCategories();
        break;
      case 2:
        _navigateToSearch();
        break;
      case 3:
        _navigateToProfile();
        break;
    }
  }

  Future<void> _navigateToSearch() async {
    final result = await Navigator.pushNamed(context, AppRoutes.searchScreen);
    if (result is int) {
      // Update bottom navigation to the returned tab index
      setState(() {
        _currentBottomNavIndex = result;
      });
    } else {
      // If no result (system back button), reset to home tab
      setState(() {
        _currentBottomNavIndex = 0;
      });
    }
  }

  Future<void> _navigateToCategories() async {
    final result = await Navigator.pushNamed(context, AppRoutes.categoriesScreen);
    if (result is int) {
      // Update bottom navigation to the returned tab index
      setState(() {
        _currentBottomNavIndex = result;
      });
    } else {
      // If no result (system back button), reset to home tab
      setState(() {
        _currentBottomNavIndex = 0;
      });
    }
  }

  Future<void> _navigateToProfile() async {
    final result = await Navigator.pushNamed(context, AppRoutes.profileScreen);
    if (result is int) {
      // Update bottom navigation to the returned tab index
      setState(() {
        _currentBottomNavIndex = result;
      });
    } else {
      // If no result (system back button), reset to home tab
      setState(() {
        _currentBottomNavIndex = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFF0D0D0D),
        body: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE50914)),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D), // Dark background
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _handleRefresh,
          color: const Color(0xFFE50914), // Netflix red
          backgroundColor: const Color(0xFF1A1A1A),
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              // Sticky Header
              SliverAppBar(
                floating: true,
                pinned: true,
                elevation: 0,
                backgroundColor: const Color(0xFF0D0D0D),
                automaticallyImplyLeading: false,
                toolbarHeight: 8.h,
                flexibleSpace: SafeArea(
                  child: HomeHeaderWidget(
                    onSearchTap: () => _navigateToSearch(),
                    onProfileTap: () {
                      Navigator.pushNamed(context, AppRoutes.profileScreen);
                    },
                  ),
                ),
              ),

              // Hero Banner - Featured Movie
              if (_featuredMovies.isNotEmpty)
                SliverToBoxAdapter(
                  child: Container(
                    margin: EdgeInsets.fromLTRB(4.w, 1.h, 4.w, 0), // Add top margin
                    child: HeroBannerWidget(
                      movie: _featuredMovies.first,
                      onWatchNowTap: () => Navigator.pushNamed(
                        context,
                        AppRoutes.contentDetailScreen,
                        arguments: _featuredMovies.first,
                      ),
                    ),
                  ),
                ),

              SliverToBoxAdapter(child: SizedBox(height: 3.h)),

              // Continue Watching Section
              if (_continueWatchingMovies.isNotEmpty)
                SliverToBoxAdapter(
                  child: ContentCarouselWidget(
                    title: "Continue Watching",
                    contentData: _convertMoviesToContentData(_continueWatchingMovies),
                    carouselType: CarouselType.continueWatching,
                    onContentTap: (content) => Navigator.pushNamed(
                      context,
                      AppRoutes.contentDetailScreen,
                      arguments: _getMovieFromContentData(content),
                    ),
                    onMoreTap: () => _navigateToCategories(),
                  ),
                ),

              SliverToBoxAdapter(child: SizedBox(height: 2.h)),

              // Trending Now Section
              if (_trendingMovies.isNotEmpty)
                SliverToBoxAdapter(
                  child: ContentCarouselWidget(
                    title: "Trending Now",
                    contentData: _convertMoviesToContentData(_trendingMovies),
                    carouselType: CarouselType.trending,
                    onContentTap: (content) => Navigator.pushNamed(
                      context,
                      AppRoutes.contentDetailScreen,
                      arguments: _getMovieFromContentData(content),
                    ),
                    onMoreTap: () => _navigateToCategories(),
                  ),
                ),

              SliverToBoxAdapter(child: SizedBox(height: 2.h)),

              // New Releases Section
              if (_newReleaseMovies.isNotEmpty)
                SliverToBoxAdapter(
                  child: ContentCarouselWidget(
                    title: "New Releases",
                    contentData: _convertMoviesToContentData(_newReleaseMovies),
                    carouselType: CarouselType.newReleases,
                    onContentTap: (content) => Navigator.pushNamed(
                      context,
                      AppRoutes.contentDetailScreen,
                      arguments: _getMovieFromContentData(content),
                    ),
                    onMoreTap: () => _navigateToCategories(),
                  ),
                ),

              SliverToBoxAdapter(child: SizedBox(height: 2.h)),

              // Action & Adventure Section
              if (_actionMovies.isNotEmpty)
                SliverToBoxAdapter(
                  child: ContentCarouselWidget(
                    title: "Action & Adventure",
                    contentData: _convertMoviesToContentData(_actionMovies),
                    carouselType: CarouselType.actionAdventure,
                    onContentTap: (content) => Navigator.pushNamed(
                      context,
                      AppRoutes.contentDetailScreen,
                      arguments: _getMovieFromContentData(content),
                    ),
                    onMoreTap: () => _navigateToCategories(),
                  ),
                ),

              SliverToBoxAdapter(child: SizedBox(height: 10.h)),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentBottomNavIndex,
        onTap: _onBottomNavTap,
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF1A1A1A),
        selectedItemColor: const Color(0xFFE50914),
        unselectedItemColor: Colors.white54,
        elevation: 8,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: 'Categories',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  // Helper methods to convert MovieModel to content data format
  Map<String, dynamic> _convertMovieToHeroData(MovieModel movie) {
    return {
      "id": movie.id,
      "title": movie.title,
      "subtitle": movie.genres.join(', '),
      "description": movie.description,
      "imageUrl": movie.backdropUrl ?? movie.posterUrl ?? '',
      "rating": movie.rating,
      "year": movie.releaseYear.toString(),
      "genre": movie.genres.isNotEmpty ? movie.genres.first : '',
    };
  }

  List<Map<String, dynamic>> _convertMoviesToContentData(List<MovieModel> movies, [bool isContinueWatching = false]) {
    return movies.map((movie) {
      if (isContinueWatching) {
        // Find corresponding watch history
        final watchHistory = _watchHistoryData.firstWhere(
          (h) => h.movieId == movie.id,
          orElse: () => WatchHistoryModel(
            id: '',
            userId: '',
            movieId: movie.id.toString(),
            watchDuration: 0,
            totalDuration: movie.duration * 60,
            isCompleted: false,
            lastWatchedAt: DateTime.now(),
            watchedAt: DateTime.now(),
          ),
        );
        
        final progress = watchHistory.totalDuration > 0 
            ? watchHistory.watchDuration / watchHistory.totalDuration 
            : 0.0;
            
        return {
          "id": movie.id,
          "title": movie.title,
          "imageUrl": movie.posterUrl ?? '',
          "progress": progress.clamp(0.0, 1.0),
          "duration": "${movie.duration} min",
          "episode": "Movie",
          "movieData": movie,
          "watchHistory": watchHistory,
        };
      } else {
        return {
          "id": movie.id,
          "title": movie.title,
          "imageUrl": movie.posterUrl ?? '',
          "rating": movie.rating,
          "year": movie.releaseYear.toString(),
          "genre": movie.genres.isNotEmpty ? movie.genres.first : '',
          "isNew": movie.releaseYear >= DateTime.now().year - 1,
          "movieData": movie,
        };
      }
    }).toList();
  }

  MovieModel _getMovieFromContentData(Map<String, dynamic> content) {
    return content["movieData"] as MovieModel;
  }
}
