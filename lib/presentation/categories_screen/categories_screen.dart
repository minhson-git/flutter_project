import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../models/category_model.dart';
import '../../services/category_service.dart';
import '../../services/movie_service.dart';
import './widgets/active_filter_chip_widget.dart';
import './widgets/category_card_widget.dart';
import './widgets/filter_bottom_sheet_widget.dart';
import '../category_movies_screen/category_movies_screen.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  List<String> _activeFilters = [];
  String _sortBy = 'popularity';
  bool _isSearchVisible = false;
  bool _isLoading = true;
  String? _errorMessage;

  // Real data from Firebase
  List<CategoryModel> _categories = [];
  Map<String, int> _categoryMovieCounts = {};

  List<CategoryModel> get _filteredCategories {
    List<CategoryModel> filtered = List.from(_categories);

    // Apply search filter
    if (_searchController.text.isNotEmpty) {
      filtered = filtered
          .where((category) => category.name
          .toLowerCase()
          .contains(_searchController.text.toLowerCase()))
          .toList();
    }

    // Apply active filters
    if (_activeFilters.isNotEmpty) {
      filtered = filtered.where((category) {
        return _categoryMatchesFilters(category);
      }).toList();
    }

    // Apply sorting
    switch (_sortBy) {
      case 'alphabetical':
        filtered.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'newest':
        filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case 'rating':
      // Sort by movie count (as popularity indicator)
        filtered.sort((a, b) {
          final countA = _categoryMovieCounts[a.name] ?? 0;
          final countB = _categoryMovieCounts[b.name] ?? 0;
          return countB.compareTo(countA);
        });
        break;
      case 'popularity':
      default:
        filtered.sort((a, b) {
          final countA = _categoryMovieCounts[a.name] ?? 0;
          final countB = _categoryMovieCounts[b.name] ?? 0;
          return countB.compareTo(countA);
        });
        break;
    }

    return filtered;
  }

  bool _categoryMatchesFilters(CategoryModel category) {
    for (String filter in _activeFilters) {
      // Check if filter matches category characteristics
      if (!_doesCategoryMatchFilter(category, filter)) {
        return false;
      }
    }
    return true;
  }

  bool _doesCategoryMatchFilter(CategoryModel category, String filter) {
    final movieCount = _categoryMovieCounts[category.name] ?? 0;

    // Genre filters (check if category name matches common genres)
    final genreFilters = ['Action', 'Adventure', 'Comedy', 'Drama', 'Horror', 'Sci-Fi', 'Romance', 'Thriller'];
    if (genreFilters.contains(filter)) {
      return category.name.toLowerCase().contains(filter.toLowerCase()) ||
          _isRelatedGenre(category.name, filter);
    }

    // Rating filters based on movie count (popularity indicator)
    if (filter.contains('Excellent')) {
      return movieCount >= 10; // Categories with many movies
    } else if (filter.contains('Very Well')) {
      return movieCount >= 7;
    } else if (filter.contains('Well')) {
      return movieCount >= 5;
    } else if (filter.contains('Pretty Good')) {
      return movieCount >= 3;
    } else if (filter.contains('Medium')) {
      return movieCount >= 1;
    }

    // Duration filters - categorize based on typical content
    if (filter == '< 30 mins') {
      return _isShortContentCategory(category.name);
    } else if (filter == '30-60 hours') {
      return _isMediumContentCategory(category.name);
    } else if (filter.contains('hour')) {
      return _isLongContentCategory(category.name);
    }

    // Release Year filters - check based on category creation time or content recency
    if (filter.contains('202')) {
      int year = int.tryParse(filter) ?? 0;
      if (year > 0) {
        return category.createdAt.year >= year;
      }
    } else if (filter == 'Older') {
      return category.createdAt.year < 2018;
    }

    return false;
  }

  bool _isRelatedGenre(String categoryName, String filter) {
    final Map<String, List<String>> relatedGenres = {
      'Action': ['action', 'fighting', 'martial arts'],
      'Adventure': ['adventure', 'exploration'],
      'Comedy': ['comedy', 'fun'],
      'Drama': ['drama', 'romance'],
      'Horror': ['horror', 'ghost', 'creepy'],
      'Sci-Fi': ['sci-fi', 'future'],
      'Romance': ['romance', 'love'],
      'Thriller': ['thriller', 'nervous'],
    };

    final related = relatedGenres[filter] ?? [];
    return related.any((keyword) =>
        categoryName.toLowerCase().contains(keyword.toLowerCase()));
  }

  bool _isShortContentCategory(String categoryName) {
    final shortCategories = ['tin tức', 'thể thao', 'âm nhạc', 'news', 'music'];
    return shortCategories.any((cat) =>
        categoryName.toLowerCase().contains(cat.toLowerCase()));
  }

  bool _isMediumContentCategory(String categoryName) {
    final mediumCategories = ['tài liệu', 'documentary', 'talk show', 'variety'];
    return mediumCategories.any((cat) =>
        categoryName.toLowerCase().contains(cat.toLowerCase()));
  }

  bool _isLongContentCategory(String categoryName) {
    final longCategories = ['phim', 'movie', 'series', 'drama', 'hành động'];
    return longCategories.any((cat) =>
        categoryName.toLowerCase().contains(cat.toLowerCase()));
  }

  @override
  void initState() {
    super.initState();
    _loadCategoriesData();
  }

  Future<void> _loadCategoriesData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      print('🔄 Loading categories from Firebase...');

      // Load categories from Firebase
      _categories = await CategoryService.getAllCategories();
      print('✅ Loaded ${_categories.length} categories');

      // Load movie counts for each category
      await _loadMovieCounts();

    } catch (e) {
      print('❌ Error loading categories: $e');
      setState(() {
        _errorMessage = 'Error loading category list: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadMovieCounts() async {
    try {
      print('🔄 Loading movie counts for categories...');
      _categoryMovieCounts.clear();

      // Get all movies once to avoid multiple API calls
      final allMovies = await MovieService.getAllMovies();

      // Count movies for each category
      for (final category in _categories) {
        final movieCount = allMovies
            .where((movie) => movie.genres.contains(category.name))
            .length;
        _categoryMovieCounts[category.name] = movieCount;
        print('📊 ${category.name}: $movieCount movies');
      }
    } catch (e) {
      print('❌ Error loading movie counts: $e');
      // Set default counts if having error
      for (final category in _categories) {
        _categoryMovieCounts[category.name] = 0;
      }
    }
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterBottomSheetWidget(
        activeFilters: _activeFilters,
        onFiltersChanged: (filters) {
          setState(() {
            _activeFilters = filters;
          });
        },
      ),
    );
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
            _buildSortOption('Popularity', 'popularity'),
            _buildSortOption('Newest', 'newest'),
            _buildSortOption('Rating', 'rating'),
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

  void _removeFilter(String filter) {
    setState(() {
      _activeFilters.remove(filter);
    });
  }

  Map<String, dynamic> _convertCategoryToMap(CategoryModel category) {
    return {
      "id": category.id,
      "name": category.name,
      "contentCount": _categoryMovieCounts[category.name] ?? 0,
      "imageUrl": category.imageUrl ?? "https://images.pexels.com/photos/1431822/pexels-photo-1431822.jpeg?auto=compress&cs=tinysrgb&w=800",
      "isFeatured": category.sortOrder <= 2, // Consider first 3 as featured
    };
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
              'An error occurred',
              style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurface
                    .withValues(alpha: 0.7),
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              _errorMessage ?? 'Unable to load category list',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurface
                    .withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 3.h),
            ElevatedButton(
              onPressed: _loadCategoriesData,
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  void _onCategoryTap(CategoryModel category) {
    // Navigate to movies by category
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CategoryMoviesScreen(
          categoryName: category.name,
        ),
      ),
    );
  }

  void _onCategoryLongPress(CategoryModel category) {
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
          children: [
            ListTile(
              leading: CustomIconWidget(
                iconName: 'favorite_border',
                color: AppTheme.lightTheme.colorScheme.onSurface,
                size: 24,
              ),
              title: Text(
                'Add to favorites',
                style: AppTheme.lightTheme.textTheme.bodyLarge,
              ),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${category.name} added to favorites'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'visibility_off',
                color: AppTheme.lightTheme.colorScheme.onSurface,
                size: 24,
              ),
              title: Text(
                'Hide category',
                style: AppTheme.lightTheme.textTheme.bodyLarge,
              ),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${category.name} hidden'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
            ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  Future<void> _onRefresh() async {
    await _loadCategoriesData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          // Handle system back button
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
          title: _isSearchVisible
              ? TextField(
            controller: _searchController,
            autofocus: true,
            style: AppTheme.lightTheme.textTheme.bodyLarge,
            decoration: InputDecoration(
              hintText: 'Search category...',
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
            'Category',
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
            Stack(
              children: [
                IconButton(
                  onPressed: _showFilterBottomSheet,
                  icon: CustomIconWidget(
                    iconName: 'filter_list',
                    color: AppTheme.lightTheme.colorScheme.onSurface,
                    size: 24,
                  ),
                ),
                _activeFilters.isNotEmpty
                    ? Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '${_activeFilters.length}',
                      style: AppTheme.lightTheme.textTheme.labelSmall
                          ?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onPrimary,
                        fontSize: 10,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
                    : const SizedBox.shrink(),
              ],
            ),
            SizedBox(width: 2.w),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: _onRefresh,
          color: AppTheme.lightTheme.colorScheme.primary,
          child: Column(
            children: [
              // Active filters
              _activeFilters.isNotEmpty
                  ? Container(
                width: double.infinity,
                padding:
                EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                child: Wrap(
                  spacing: 2.w,
                  runSpacing: 1.h,
                  children: _activeFilters
                      .map((filter) => ActiveFilterChipWidget(
                    label: filter,
                    onRemove: () => _removeFilter(filter),
                  ))
                      .toList(),
                ),
              )
                  : const SizedBox.shrink(),

              // Categories grid
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _errorMessage != null
                    ? _buildErrorState()
                    : _filteredCategories.isEmpty
                    ? _buildEmptyState()
                    : Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  child: GridView.builder(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount:
                      SizerUtil.deviceType == DeviceType.tablet ? 3 : 2,
                      crossAxisSpacing: 4.w,
                      mainAxisSpacing: 2.h,
                      childAspectRatio: 0.8,
                    ),
                    itemCount: _filteredCategories.length,
                    itemBuilder: (context, index) {
                      final category = _filteredCategories[index];
                      return CategoryCardWidget(
                        category: _convertCategoryToMap(category),
                        onTap: () => _onCategoryTap(category),
                        onLongPress: () => _onCategoryLongPress(category),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _showSortOptions,
          backgroundColor: AppTheme.lightTheme.colorScheme.primary,
          child: CustomIconWidget(
            iconName: 'sort',
            color: AppTheme.lightTheme.colorScheme.onPrimary,
            size: 24,
          ),
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
              iconName: 'category',
              color: AppTheme.lightTheme.colorScheme.onSurface
                  .withValues(alpha: 0.5),
              size: 80,
            ),
            SizedBox(height: 3.h),
            Text(
              'No category found',
              style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurface
                    .withValues(alpha: 0.7),
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              'Try adjusting your search or filters',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurface
                    .withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 3.h),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/home-screen');
              },
              child: const Text('Explore all content'),
            ),
          ],
        ),
      ),
    );
  }
}
