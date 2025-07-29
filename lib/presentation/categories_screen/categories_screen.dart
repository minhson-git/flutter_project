import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/active_filter_chip_widget.dart';
import './widgets/category_card_widget.dart';
import './widgets/filter_bottom_sheet_widget.dart';

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

  // Mock data for categories
  final List<Map<String, dynamic>> _categories = [
    {
      "id": 1,
      "name": "Action & Adventure",
      "contentCount": 245,
      "imageUrl":
      "https://images.pexels.com/photos/1431822/pexels-photo-1431822.jpeg?auto=compress&cs=tinysrgb&w=800",
      "isFeatured": true,
    },
    {
      "id": 2,
      "name": "Drama",
      "contentCount": 189,
      "imageUrl":
      "https://images.pexels.com/photos/7991579/pexels-photo-7991579.jpeg?auto=compress&cs=tinysrgb&w=800",
      "isFeatured": false,
    },
    {
      "id": 3,
      "name": "Comedy",
      "contentCount": 156,
      "imageUrl":
      "https://images.pexels.com/photos/7991319/pexels-photo-7991319.jpeg?auto=compress&cs=tinysrgb&w=800",
      "isFeatured": false,
    },
    {
      "id": 4,
      "name": "Horror",
      "contentCount": 98,
      "imageUrl":
      "https://images.pexels.com/photos/2873486/pexels-photo-2873486.jpeg?auto=compress&cs=tinysrgb&w=800",
      "isFeatured": false,
    },
    {
      "id": 5,
      "name": "Sci-Fi",
      "contentCount": 134,
      "imageUrl":
      "https://images.pexels.com/photos/2159065/pexels-photo-2159065.jpeg?auto=compress&cs=tinysrgb&w=800",
      "isFeatured": true,
    },
    {
      "id": 6,
      "name": "Romance",
      "contentCount": 112,
      "imageUrl":
      "https://images.pexels.com/photos/1024993/pexels-photo-1024993.jpeg?auto=compress&cs=tinysrgb&w=800",
      "isFeatured": false,
    },
    {
      "id": 7,
      "name": "Thriller",
      "contentCount": 87,
      "imageUrl":
      "https://images.pexels.com/photos/1666779/pexels-photo-1666779.jpeg?auto=compress&cs=tinysrgb&w=800",
      "isFeatured": false,
    },
    {
      "id": 8,
      "name": "Documentary",
      "contentCount": 76,
      "imageUrl":
      "https://images.pexels.com/photos/3184465/pexels-photo-3184465.jpeg?auto=compress&cs=tinysrgb&w=800",
      "isFeatured": false,
    },
    {
      "id": 9,
      "name": "Animation",
      "contentCount": 145,
      "imageUrl":
      "https://images.pexels.com/photos/7991579/pexels-photo-7991579.jpeg?auto=compress&cs=tinysrgb&w=800",
      "isFeatured": false,
    },
    {
      "id": 10,
      "name": "Fantasy",
      "contentCount": 92,
      "imageUrl":
      "https://images.pexels.com/photos/1666779/pexels-photo-1666779.jpeg?auto=compress&cs=tinysrgb&w=800",
      "isFeatured": false,
    },
  ];

  List<Map<String, dynamic>> get _filteredCategories {
    List<Map<String, dynamic>> filtered = List.from(_categories);

    // Apply search filter
    if (_searchController.text.isNotEmpty) {
      filtered = filtered
          .where((category) => (category["name"] as String)
          .toLowerCase()
          .contains(_searchController.text.toLowerCase()))
          .toList();
    }

    // Apply sorting
    switch (_sortBy) {
      case 'alphabetical':
        filtered.sort(
                (a, b) => (a["name"] as String).compareTo(b["name"] as String));
        break;
      case 'newest':
      // Mock sorting by newest (reverse order for demo)
        filtered = filtered.reversed.toList();
        break;
      case 'rating':
      // Mock sorting by rating (shuffle for demo)
        filtered.shuffle();
        break;
      case 'popularity':
      default:
        filtered.sort((a, b) =>
            (b["contentCount"] as int).compareTo(a["contentCount"] as int));
        break;
    }

    return filtered;
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

  void _onCategoryTap(Map<String, dynamic> category) {
    Navigator.pushNamed(context, '/content-detail-screen');
  }

  void _onCategoryLongPress(Map<String, dynamic> category) {
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
                'Add to Favorites',
                style: AppTheme.lightTheme.textTheme.bodyLarge,
              ),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${category["name"]} added to favorites'),
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
                'Hide Category',
                style: AppTheme.lightTheme.textTheme.bodyLarge,
              ),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${category["name"]} hidden'),
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
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      // Simulate refresh by shuffling categories
      _categories.shuffle();
    });
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
        title: _isSearchVisible
            ? TextField(
          controller: _searchController,
          autofocus: true,
          style: AppTheme.lightTheme.textTheme.bodyLarge,
          decoration: InputDecoration(
            hintText: 'Search categories...',
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
          'Categories',
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
              child: _filteredCategories.isEmpty
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
                      category: category,
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
              'No categories found',
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
              child: const Text('Explore All Content'),
            ),
          ],
        ),
      ),
    );
  }
}
