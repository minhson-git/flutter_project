import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../models/movie_model.dart';
import '../../services/movie_service.dart';
import '../content_detail_screen/content_detail_screen.dart';
import './widgets/movie_grid_card.dart';

class CategoryMoviesScreen extends StatefulWidget {
  final String categoryName;
  
  const CategoryMoviesScreen({
    super.key,
    required this.categoryName,
  });

  @override
  State<CategoryMoviesScreen> createState() => _CategoryMoviesScreenState();
}

class _CategoryMoviesScreenState extends State<CategoryMoviesScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  List<MovieModel> _movies = [];
  bool _isLoading = true;
  String? _errorMessage;
  bool _isSearchVisible = false;
  String _sortBy = 'rating'; // rating, newest, alphabetical, popularity
  bool _isGridView = true; // true for grid, false for list

  
  @override
  void initState() {
    super.initState();
    _loadMovies();
  }

  Future<void> _loadMovies() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      print('🔄 Loading movies for category: ${widget.categoryName}');
      
      // Load movies by genre/category
      _movies = await MovieService.getMoviesByGenre(widget.categoryName);
      
      print('✅ Loaded ${_movies.length} movies for ${widget.categoryName}');
    } catch (e) {
      print('❌ Error loading movies: $e');
      setState(() {
        _errorMessage = 'Error loading movie list: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  List<MovieModel> get _filteredAndSortedMovies {
    List<MovieModel> filtered = List.from(_movies);

    // Apply search filter
    if (_searchController.text.isNotEmpty) {
      filtered = filtered
          .where((movie) => movie.title
              .toLowerCase()
              .contains(_searchController.text.toLowerCase()))
          .toList();
    }

    // Apply sorting
    switch (_sortBy) {
      case 'alphabetical':
        filtered.sort((a, b) => a.title.compareTo(b.title));
        break;
      case 'newest':
        filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case 'popularity':
        filtered.sort((a, b) => b.viewCount.compareTo(a.viewCount));
        break;
      case 'rating':
      default:
        filtered.sort((a, b) => b.rating.compareTo(a.rating));
        break;
    }

    return filtered;
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.lightTheme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sort by',
              style: AppTheme.lightTheme.textTheme.titleLarge,
            ),
            SizedBox(height: 2.h),
            _buildSortOption('Top Rated', 'rating'),
            _buildSortOption('Newest', 'newest'),
            _buildSortOption('Most Popular', 'popularity'),
            _buildSortOption('Alphabetical', 'alphabetical'),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  Widget _buildSortOption(String title, String value) {
    return ListTile(
      title: Text(
        title,
        style: AppTheme.lightTheme.textTheme.bodyLarge,
      ),
      trailing: _sortBy == value
          ? CustomIconWidget(
              iconName: 'check',
              color: AppTheme.lightTheme.colorScheme.primary,
              size: 20,
            )
          : null,
      onTap: () {
        setState(() {
          _sortBy = value;
        });
        Navigator.pop(context);
      },
    );
  }

  void _onMovieTap(MovieModel movie) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ContentDetailScreen(),
        settings: RouteSettings(arguments: movie),
      ),
    );
  }

  Future<void> _onRefresh() async {
    await _loadMovies();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: CustomIconWidget(
            iconName: 'arrow_back',
            color: AppTheme.lightTheme.colorScheme.onSurface,
            size: 24,
          ),
        ),
        title: _isSearchVisible
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: AppTheme.lightTheme.textTheme.bodyLarge,
                decoration: InputDecoration(
                  hintText: 'Search for movies...',
                  hintStyle: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurface
                        .withValues(alpha: 0.6),
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                onChanged: (value) {
                  setState(() {});
                },
              )
            : Text(
                widget.categoryName,
                style: AppTheme.lightTheme.textTheme.titleLarge,
              ),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _isSearchVisible = !_isSearchVisible;
                if (!_isSearchVisible) {
                  _searchController.clear();
                }
              });
            },
            icon: CustomIconWidget(
              iconName: _isSearchVisible ? 'close' : 'search',
              color: AppTheme.lightTheme.colorScheme.onSurface,
              size: 24,
            ),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                _isGridView = !_isGridView;
              });
            },
            icon: CustomIconWidget(
              iconName: _isGridView ? 'view_list' : 'grid_view',
              color: AppTheme.lightTheme.colorScheme.onSurface,
              size: 24,
            ),
          ),
          IconButton(
            onPressed: _showSortOptions,
            icon: CustomIconWidget(
              iconName: 'sort',
              color: AppTheme.lightTheme.colorScheme.onSurface,
              size: 24,
            ),
          ),
          SizedBox(width: 2.w),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        color: AppTheme.lightTheme.colorScheme.primary,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null
                ? _buildErrorState()
                : _filteredAndSortedMovies.isEmpty
                    ? _buildEmptyState()
                    : _buildMoviesList(),
      ),
    );
  }

  Widget _buildMoviesList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Movies count
        Padding(
          padding: EdgeInsets.all(4.w),
          child: Text(
            '${_filteredAndSortedMovies.length} movie',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurface
                  .withValues(alpha: 0.7),
            ),
          ),
        ),
        
        // Movies grid/list
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: _isGridView ? _buildGridView() : _buildListView(),
          ),
        ),
      ],
    );
  }

  Widget _buildGridView() {
    return GridView.builder(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: SizerUtil.deviceType == DeviceType.tablet ? 4 : 2,
        crossAxisSpacing: 4.w,
        mainAxisSpacing: 2.h,
        childAspectRatio: 0.65,
      ),
      itemCount: _filteredAndSortedMovies.length,
      itemBuilder: (context, index) {
        final movie = _filteredAndSortedMovies[index];
        return MovieGridCard(
          movie: movie,
          onTap: () => _onMovieTap(movie),
        );
      },
    );
  }

  Widget _buildListView() {
    return ListView.builder(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: _filteredAndSortedMovies.length,
      itemBuilder: (context, index) {
        final movie = _filteredAndSortedMovies[index];
        return _buildListItem(movie);
      },
    );
  }

  Widget _buildListItem(MovieModel movie) {
    return GestureDetector(
      onTap: () => _onMovieTap(movie),
      child: Container(
        margin: EdgeInsets.only(bottom: 2.h),
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Movie poster
            Container(
              width: 20.w,
              height: 28.w,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: movie.posterUrl?.isNotEmpty == true
                    ? DecorationImage(
                        image: NetworkImage(movie.posterUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
                color: movie.posterUrl?.isEmpty != false
                    ? Colors.grey[300]
                    : null,
              ),
              child: movie.posterUrl?.isEmpty != false
                  ? const Center(
                      child: Icon(
                        Icons.movie,
                        size: 30,
                        color: Colors.grey,
                      ),
                    )
                  : null,
            ),
            SizedBox(width: 3.w),
            
            // Movie info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    movie.title,
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 1.h),
                  
                  // Rating and year
                  Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'star',
                        color: Colors.amber,
                        size: 16,
                      ),
                      SizedBox(width: 1.w),
                      Text(
                        movie.rating.toStringAsFixed(1),
                        style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(width: 3.w),
                      Text(
                        '${movie.releaseYear}',
                        style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                          color: AppTheme.lightTheme.colorScheme.onSurface
                              .withValues(alpha: 0.7),
                        ),
                      ),
                      SizedBox(width: 3.w),
                      Text(
                        '${movie.duration} min',
                        style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                          color: AppTheme.lightTheme.colorScheme.onSurface
                              .withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 1.h),
                  
                  // Description
                  Text(
                    movie.description,
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurface
                          .withValues(alpha: 0.8),
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 1.h),
                  
                  // Genres
                  if (movie.genres.isNotEmpty)
                    Wrap(
                      spacing: 1.w,
                      runSpacing: 0.5.h,
                      children: movie.genres.take(3).map((genre) {
                        return Container(
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
                            genre,
                            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                              color: AppTheme.lightTheme.colorScheme.primary,
                              fontSize: 10.sp,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(8.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: 'error_outline',
              color: Colors.red.withValues(alpha: 0.7),
              size: 80,
            ),
            SizedBox(height: 3.h),
            Text(
              'An error occurred.',
              style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurface
                    .withValues(alpha: 0.7),
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              _errorMessage ?? 'Unable to load movie list',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurface
                    .withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 3.h),
            ElevatedButton(
              onPressed: _loadMovies,
              child: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(8.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: 'movie',
              color: AppTheme.lightTheme.colorScheme.onSurface
                  .withValues(alpha: 0.5),
              size: 80,
            ),
            SizedBox(height: 3.h),
            Text(
              'Movie not found',
              style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurface
                    .withValues(alpha: 0.7),
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              'There are no movies in this category "${widget.categoryName}"',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurface
                    .withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 3.h),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Back'),
            ),
          ],
        ),
      ),
    );
  }
}
