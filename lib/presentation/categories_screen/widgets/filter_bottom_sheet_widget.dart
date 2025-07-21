import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class FilterBottomSheetWidget extends StatefulWidget {
  final List<String> activeFilters;
  final Function(List<String>) onFiltersChanged;

  const FilterBottomSheetWidget({
    super.key,
    required this.activeFilters,
    required this.onFiltersChanged,
  });

  @override
  State<FilterBottomSheetWidget> createState() =>
      _FilterBottomSheetWidgetState();
}

class _FilterBottomSheetWidgetState extends State<FilterBottomSheetWidget> {
  late List<String> _selectedFilters;

  final Map<String, List<String>> _filterOptions = {
    'Genre': [
      'Action',
      'Adventure',
      'Comedy',
      'Drama',
      'Horror',
      'Sci-Fi',
      'Romance',
      'Thriller'
    ],
    'Release Year': [
      '2024',
      '2023',
      '2022',
      '2021',
      '2020',
      '2019',
      '2018',
      'Older'
    ],
    'Rating': [
      '9+ Excellent',
      '8+ Very Good',
      '7+ Good',
      '6+ Fair',
      '5+ Average'
    ],
    'Duration': ['< 30 min', '30-60 min', '1-2 hours', '2-3 hours', '3+ hours'],
  };

  @override
  void initState() {
    super.initState();
    _selectedFilters = List.from(widget.activeFilters);
  }

  void _toggleFilter(String filter) {
    setState(() {
      _selectedFilters.contains(filter)
          ? _selectedFilters.remove(filter)
          : _selectedFilters.add(filter);
    });
  }

  void _clearAllFilters() {
    setState(() {
      _selectedFilters.clear();
    });
  }

  void _applyFilters() {
    widget.onFiltersChanged(_selectedFilters);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80.h,
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: EdgeInsets.only(top: 1.h),
            width: 10.w,
            height: 0.5.h,
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.onSurface
                  .withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: EdgeInsets.all(4.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filters',
                  style: AppTheme.lightTheme.textTheme.titleLarge,
                ),
                Row(
                  children: [
                    TextButton(
                      onPressed: _clearAllFilters,
                      child: Text(
                        'Clear All',
                        style:
                            AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                          color: AppTheme.lightTheme.colorScheme.primary,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: CustomIconWidget(
                        iconName: 'close',
                        color: AppTheme.lightTheme.colorScheme.onSurface,
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Filter sections
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              children: _filterOptions.entries
                  .map((entry) => _buildFilterSection(entry.key, entry.value))
                  .toList(),
            ),
          ),

          // Apply button
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surface,
              border: Border(
                top: BorderSide(
                  color: AppTheme.lightTheme.colorScheme.outline
                      .withValues(alpha: 0.2),
                ),
              ),
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _applyFilters,
                child: Text(
                  'Apply Filters${_selectedFilters.isNotEmpty ? ' (${_selectedFilters.length})' : ''}',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection(String title, List<String> options) {
    return ExpansionTile(
      title: Text(
        title,
        style: AppTheme.lightTheme.textTheme.titleMedium,
      ),
      iconColor: AppTheme.lightTheme.colorScheme.primary,
      collapsedIconColor: AppTheme.lightTheme.colorScheme.onSurface,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
          child: Wrap(
            spacing: 2.w,
            runSpacing: 1.h,
            children:
                options.map((option) => _buildFilterChip(option)).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String option) {
    final bool isSelected = _selectedFilters.contains(option);

    return FilterChip(
      label: Text(
        option,
        style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
          color: isSelected
              ? AppTheme.lightTheme.colorScheme.onPrimary
              : AppTheme.lightTheme.colorScheme.onSurface,
        ),
      ),
      selected: isSelected,
      onSelected: (_) => _toggleFilter(option),
      backgroundColor: AppTheme.lightTheme.colorScheme.surfaceContainer,
      selectedColor: AppTheme.lightTheme.colorScheme.primary,
      checkmarkColor: AppTheme.lightTheme.colorScheme.onPrimary,
      side: BorderSide(
        color: isSelected
            ? AppTheme.lightTheme.colorScheme.primary
            : AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.3),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }
}
