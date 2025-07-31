import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/app_export.dart';
import '../../models/category_model.dart';
import '../../models/movie_model.dart';
import '../../services/category_service.dart';
import '../../services/movie_service.dart';
import './widgets/empty_state_widget.dart';
import './widgets/filter_chips_widget.dart';
import './widgets/recent_searches_widget.dart';
import './widgets/search_bar_widget.dart';
import './widgets/search_results_widget.dart';
import './widgets/search_suggestions_widget.dart';
import './widgets/trending_searches_widget.dart';
import '../content_detail_screen/content_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  // Constants
  static const String _recentSearchesKey = 'recent_searches';
  static const int _maxRecentSearches = 10;

  bool _isSearching = false;
  bool _isLoading = false;
  String _searchQuery = '';
  String? _errorMessage;
  final List<String> _selectedFilters = [];

  // Real data from Firebase
  List<MovieModel> _searchResults = [];
  List<String> _recentSearches = [];
  List<String> _trendingSearches = [];
  List<String> _searchSuggestions = [];

  final List<String> _filterOptions = [
    'Phim lẻ',
    'Phim bộ',
    'Action',
    'Adventure',
    'Comedy',
    'Drama',
    'Horror',
    'Sci-Fi',
    'Romance',
    'Thriller',
    '2024',
    '2023',
    '2022',
    '2021',
    'HD',
    '4K'
  ];

  @override
  void initState() {
    super.initState();
    _loadInitialData();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocusNode.requestFocus();
    });

    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
        _isSearching = _searchQuery.isNotEmpty;
      });

      // Generate suggestions based on query
      if (_searchQuery.length >= 2) {
        _generateSearchSuggestions();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchSubmitted(String query) {
    if (query.trim().isNotEmpty) {
      setState(() {
        _isSearching = true;
      });

      // Add to recent searches
      _addToRecentSearches(query.trim());

      _searchFocusNode.unfocus();
      _performSearch(query);
    }
  }

  Future<void> _loadInitialData() async {
    try {
      await _loadTrendingSearches();
      await _loadRecentSearches();
    } catch (e) {
      print('Error loading initial data: $e');
    }
  }

  Future<void> _loadTrendingSearches() async {
    try {
      // Load popular genres and recent movies as trending searches
      final categories = await CategoryService.getAllCategories();
      final popularMovies = await MovieService.getPopularMovies();

      setState(() {
        _trendingSearches = [
          ...categories.take(6).map((cat) => cat.name),
          ...popularMovies.take(4).map((movie) => movie.title),
        ];
      });
    } catch (e) {
      print('❌ Error loading trending searches: $e');
      // Fallback trending searches
      setState(() {
        _trendingSearches = [
          'Action',
          'Comedy',
          'Drama',
          'Horror',
          'Sci-Fi',
          'Romance'
        ];
      });
    }
  }

  Future<void> _loadRecentSearches() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final recentSearches = prefs.getStringList(_recentSearchesKey) ?? [];

      setState(() {
        _recentSearches = recentSearches;
      });

      print('📜 Loaded ${_recentSearches.length} recent searches');
    } catch (e) {
      print('❌ Error loading recent searches: $e');
      setState(() {
        _recentSearches = [];
      });
    }
  }

  Future<void> _saveRecentSearches() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_recentSearchesKey, _recentSearches);
      print('💾 Saved ${_recentSearches.length} recent searches');
    } catch (e) {
      print('❌ Error saving recent searches: $e');
    }
  }

  Future<void> _addToRecentSearches(String query) async {
    if (query.trim().isEmpty) return;

    setState(() {
      // Remove if already exists
      _recentSearches.remove(query);
      // Add to beginning
      _recentSearches.insert(0, query);
      // Keep only max items
      if (_recentSearches.length > _maxRecentSearches) {
        _recentSearches = _recentSearches.take(_maxRecentSearches).toList();
      }
    });

    // Save to persistent storage
    await _saveRecentSearches();
  }

  Future<void> _generateSearchSuggestions() async {
    try {
      // Search for movies that match the current query
      final movies = await MovieService.searchMovies(_searchQuery);
      setState(() {
        _searchSuggestions = movies
            .where((movie) => movie.title.toLowerCase().contains(_searchQuery.toLowerCase()))
            .take(5)
            .map((movie) => movie.title)
            .toList();
      });
    } catch (e) {
      print('❌ Error generating suggestions: $e');
    }
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _searchResults.clear();
    });

    try {
      print('🔍 Searching for: $query');

      // Search movies
      List<MovieModel> allResults = await MovieService.searchMovies(query);

      // Also search by genre if query matches
      final categories = await CategoryService.getAllCategories();
      final matchingCategory = categories.firstWhere(
            (cat) => cat.name.toLowerCase().contains(query.toLowerCase()),
        orElse: () => CategoryModel(
          name: '',
          description: '',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );

      if (matchingCategory.id?.isNotEmpty == true) {
        final genreMovies = await MovieService.getMoviesByGenre(matchingCategory.name);
        allResults.addAll(genreMovies);
      }

      // Remove duplicates
      final uniqueResults = <String, MovieModel>{};
      for (var movie in allResults) {
        uniqueResults[movie.id.toString()] = movie;
      }

      // Apply filters
      List<MovieModel> filteredResults = uniqueResults.values.toList();
      filteredResults = _applyFilters(filteredResults);

      setState(() {
        _searchResults = filteredResults;
        _isLoading = false;
      });

      print('✅ Found ${_searchResults.length} results');

    } catch (e) {
      print('❌ Search error: $e');
      setState(() {
        _errorMessage = 'Lỗi tìm kiếm: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  List<MovieModel> _applyFilters(List<MovieModel> movies) {
    List<MovieModel> filtered = List.from(movies);

    for (String filter in _selectedFilters) {
      switch (filter) {
        case 'Phim lẻ':
        // Filter for movies (single films)
          filtered = filtered.where((movie) =>
          !movie.genres.contains('Series') &&
              !movie.title.toLowerCase().contains('season')).toList();
          break;
        case 'Phim bộ':
        // Filter for series
          filtered = filtered.where((movie) =>
          movie.genres.contains('Series') ||
              movie.title.toLowerCase().contains('season')).toList();
          break;
        case '2024':
        case '2023':
        case '2022':
        case '2021':
          int year = int.parse(filter);
          filtered = filtered.where((movie) => movie.releaseYear == year).toList();
          break;
        case 'HD':
          filtered = filtered.where((movie) => movie.quality?.contains('HD') == true).toList();
          break;
        case '4K':
          filtered = filtered.where((movie) => movie.quality?.contains('4K') == true).toList();
          break;
        default:
        // Genre filters
          filtered = filtered.where((movie) =>
              movie.genres.any((genre) =>
                  genre.toLowerCase().contains(filter.toLowerCase()))).toList();
      }
    }

    return filtered;
  }

  void _removeRecentSearch(String search) {
    setState(() {
      _recentSearches.remove(search);
    });
    _saveRecentSearches();
  }

  void _clearAllRecentSearches() {
    setState(() {
      _recentSearches.clear();
    });
    _saveRecentSearches();
  }

  void _onFilterToggle(String filter) {
    setState(() {
      if (_selectedFilters.contains(filter)) {
        _selectedFilters.remove(filter);
      } else {
        _selectedFilters.add(filter);
      }
    });

    // Re-apply filters to current results
    if (_isSearching && _searchQuery.isNotEmpty) {
      _performSearch(_searchQuery);
    }
  }

  void _onTrendingSearchTap(String search) {
    _searchController.text = search;
    _onSearchSubmitted(search);
  }

  void _onSuggestionTap(String suggestion) {
    _searchController.text = suggestion;
    _onSearchSubmitted(suggestion);
  }

  void _onResultTap(dynamic result) {
    if (result is MovieModel) {
      print('🔍 Navigating to movie: ${result.title}');
      print('Movie ID: ${result.id}');

      // Validate movie data before navigation
      if (result.title.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Dữ liệu phim không hợp lệ')),
        );
        return;
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ContentDetailScreen(movie: result),
        ),
      );
    } else if (result is Map<String, dynamic>) {
      // Handle legacy map format if needed
      Navigator.pushNamed(context, '/content-detail-screen');
    }
  }

  Widget _buildSearchContent() {
    if (_searchQuery.isEmpty) {
      return SingleChildScrollView(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_recentSearches.isNotEmpty) ...[
              RecentSearchesWidget(
                recentSearches: _recentSearches,
                onSearchTap: (search) {
                  _searchController.text = search;
                  _onSearchSubmitted(search);
                },
                onRemoveSearch: _removeRecentSearch,
                onClearAll: _clearAllRecentSearches,
              ),
              SizedBox(height: 3.h),
            ] else ...[
              // Show placeholder when no recent searches
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
                  ),
                ),
                child: Column(
                  children: [
                    CustomIconWidget(
                      iconName: 'history',
                      color: AppTheme.lightTheme.colorScheme.onSurface.withValues(alpha: 0.5),
                      size: 40,
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'Chưa có lịch sử tìm kiếm',
                      style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      'Tìm kiếm phim yêu thích để xây dựng lịch sử của bạn',
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 3.h),
            ],
            TrendingSearchesWidget(
              trendingSearches: _trendingSearches,
              onTrendingTap: _onTrendingSearchTap,
            ),
          ],
        ),
      );
    }

    if (_searchQuery.length < 2) {
      return const EmptyStateWidget(
        type: EmptyStateType.noQuery,
      );
    }

    // Show loading state
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    // Show error state
    if (_errorMessage != null) {
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
                'Có lỗi xảy ra',
                style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurface
                      .withValues(alpha: 0.7),
                ),
              ),
              SizedBox(height: 1.h),
              Text(
                _errorMessage!,
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurface
                      .withValues(alpha: 0.6),
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 3.h),
              ElevatedButton(
                onPressed: () => _performSearch(_searchQuery),
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      );
    }

    if (_isSearching && _searchResults.isEmpty && !_isLoading) {
      return const EmptyStateWidget(
        type: EmptyStateType.noResults,
      );
    }

    return Column(
      children: [
        if (_searchQuery.length >= 2 && !_isSearching) ...[
          SearchSuggestionsWidget(
            suggestions: _searchSuggestions,
            onSuggestionTap: _onSuggestionTap,
            searchQuery: _searchQuery,
          ),
        ] else if (_isSearching) ...[
          FilterChipsWidget(
            filters: _filterOptions,
            selectedFilters: _selectedFilters,
            onFilterToggle: _onFilterToggle,
          ),
          SizedBox(height: 2.h),
          Expanded(
            child: SearchResultsWidget(
              results: _searchResults,
              onResultTap: _onResultTap,
            ),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          // This is called when the route is actually popped
          // We can't change the result here, but we can ensure 
          // the navigation handles it properly
        }
      },
      child: Scaffold(
        backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
          elevation: 0,
          leading: IconButton(
            onPressed: () {
              // Pop with result to indicate which tab should be selected
              Navigator.pop(context, 0); // Return to home tab (index 0)
            },
            icon: CustomIconWidget(
              iconName: 'arrow_back',
              color: AppTheme.lightTheme.colorScheme.onSurface,
              size: 24,
            ),
          ),
          title: Text(
            'Tìm kiếm',
            style: AppTheme.lightTheme.textTheme.titleLarge,
          ),
        ),
        body: Column(
          children: [
            SearchBarWidget(
              controller: _searchController,
              focusNode: _searchFocusNode,
              onSubmitted: _onSearchSubmitted,
            ),
            Expanded(
              child: _buildSearchContent(),
            ),
          ],
        ),
      ),
    );
  }
}
