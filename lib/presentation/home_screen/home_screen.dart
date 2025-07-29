import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/content_carousel_widget.dart';
import './widgets/hero_banner_widget.dart';
import './widgets/home_header_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late ScrollController _scrollController;
  int _currentBottomNavIndex = 0;
  bool _isRefreshing = false;

  // Mock data for content
  final List<Map<String, dynamic>> continueWatchingData = [
    {
      "id": 1,
      "title": "Stranger Things",
      "imageUrl":
          "https://images.unsplash.com/photo-1489599162163-3fb4b4b0b0e4?w=300&h=450&fit=crop",
      "progress": 0.65,
      "duration": "45 min",
      "episode": "S4 E7"
    },
    {
      "id": 2,
      "title": "The Witcher",
      "imageUrl":
          "https://images.pexels.com/photos/7991579/pexels-photo-7991579.jpeg?w=300&h=450&fit=crop",
      "progress": 0.32,
      "duration": "52 min",
      "episode": "S2 E3"
    },
    {
      "id": 3,
      "title": "Ozark",
      "imageUrl":
          "https://images.pixabay.com/photo/2019/04/26/07/14/store-4156934_1280.jpg?w=300&h=450&fit=crop",
      "progress": 0.78,
      "duration": "48 min",
      "episode": "S3 E5"
    }
  ];

  final List<Map<String, dynamic>> trendingNowData = [
    {
      "id": 4,
      "title": "Wednesday",
      "imageUrl":
          "https://images.unsplash.com/photo-1574375927938-d5a98e8ffe85?w=300&h=450&fit=crop",
      "rating": 8.5,
      "year": "2022",
      "genre": "Mystery"
    },
    {
      "id": 5,
      "title": "House of Dragon",
      "imageUrl":
          "https://images.pexels.com/photos/8111357/pexels-photo-8111357.jpeg?w=300&h=450&fit=crop",
      "rating": 9.2,
      "year": "2022",
      "genre": "Fantasy"
    },
    {
      "id": 6,
      "title": "The Bear",
      "imageUrl":
          "https://images.pixabay.com/photo/2017/11/24/10/43/ticket-2974645_1280.jpg?w=300&h=450&fit=crop",
      "rating": 8.8,
      "year": "2022",
      "genre": "Comedy"
    }
  ];

  final List<Map<String, dynamic>> newReleasesData = [
    {
      "id": 7,
      "title": "Glass Onion",
      "imageUrl":
          "https://images.unsplash.com/photo-1489599162163-3fb4b4b0b0e4?w=300&h=450&fit=crop",
      "releaseDate": "2023-12-15",
      "genre": "Mystery",
      "isNew": true
    },
    {
      "id": 8,
      "title": "Avatar 2",
      "imageUrl":
          "https://images.pexels.com/photos/7991579/pexels-photo-7991579.jpeg?w=300&h=450&fit=crop",
      "releaseDate": "2023-12-10",
      "genre": "Sci-Fi",
      "isNew": true
    },
    {
      "id": 9,
      "title": "Top Gun Maverick",
      "imageUrl":
          "https://images.pixabay.com/photo/2019/04/26/07/14/store-4156934_1280.jpg?w=300&h=450&fit=crop",
      "releaseDate": "2023-12-08",
      "genre": "Action",
      "isNew": true
    }
  ];

  final List<Map<String, dynamic>> actionAdventureData = [
    {
      "id": 10,
      "title": "John Wick 4",
      "imageUrl":
          "https://images.unsplash.com/photo-1574375927938-d5a98e8ffe85?w=300&h=450&fit=crop",
      "rating": 8.9,
      "year": "2023",
      "genre": "Action"
    },
    {
      "id": 11,
      "title": "Mission Impossible",
      "imageUrl":
          "https://images.pexels.com/photos/8111357/pexels-photo-8111357.jpeg?w=300&h=450&fit=crop",
      "rating": 8.7,
      "year": "2023",
      "genre": "Adventure"
    },
    {
      "id": 12,
      "title": "Fast X",
      "imageUrl":
          "https://images.pixabay.com/photo/2017/11/24/10/43/ticket-2974645_1280.jpg?w=300&h=450&fit=crop",
      "rating": 7.8,
      "year": "2023",
      "genre": "Action"
    }
  ];

  final List<Map<String, dynamic>> heroData = [
    {
      "id": 13,
      "title": "The Last of Us",
      "subtitle": "Experience the post-apocalyptic world",
      "description":
          "A gripping tale of survival in a world overrun by infected creatures.",
      "imageUrl":
          "https://images.unsplash.com/photo-1489599162163-3fb4b4b0b0e4?w=800&h=600&fit=crop",
      "rating": 9.5,
      "year": "2023",
      "genre": "Drama"
    }
  ];

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
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

    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isRefreshing = false;
    });
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
        Navigator.pushNamed(context, '/categories-screen');
        break;
      case 2:
        Navigator.pushNamed(context, '/search-screen');
        break;
      case 3:
      // Profile - could navigate to profile screen
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _handleRefresh,
          color: AppTheme.lightTheme.primaryColor,
          backgroundColor: AppTheme.lightTheme.colorScheme.surface,
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              // Sticky Header
              SliverAppBar(
                floating: true,
                pinned: true,
                elevation: 0,
                backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
                automaticallyImplyLeading: false,
                flexibleSpace: HomeHeaderWidget(
                  onSearchTap: () =>
                      Navigator.pushNamed(context, '/search-screen'),
                  onProfileTap: () {
                    // Handle profile tap
                  },
                ),
              ),
              SliverToBoxAdapter(
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 4.w),
                  child: HeroBannerWidget(
                    heroData: heroData.isNotEmpty ? heroData.first : {},
                    onWatchNowTap: () =>
                        Navigator.pushNamed(context, '/content-detail-screen'),
                  ),
                ),
              ),

              SliverToBoxAdapter(child: SizedBox(height: 3.h)),

              if (continueWatchingData.isNotEmpty)
                SliverToBoxAdapter(
                  child: ContentCarouselWidget(
                    title: "Continue Watching",
                    contentData: continueWatchingData,
                    carouselType: CarouselType.continueWatching,
                    onContentTap: (content) =>
                        Navigator.pushNamed(context, '/content-detail-screen'),
                    onMoreTap: () =>
                        Navigator.pushNamed(context, '/categories-screen'),
                  ),
                ),

              SliverToBoxAdapter(child: SizedBox(height: 2.h)),

              SliverToBoxAdapter(
                child: ContentCarouselWidget(
                  title: "Trending Now",
                  contentData: trendingNowData,
                  carouselType: CarouselType.trending,
                  onContentTap: (content) =>
                      Navigator.pushNamed(context, '/content-detail-screen'),
                  onMoreTap: () =>
                      Navigator.pushNamed(context, '/categories-screen'),
                ),
              ),

              SliverToBoxAdapter(child: SizedBox(height: 2.h)),

              SliverToBoxAdapter(
                child: ContentCarouselWidget(
                  title: "New Releases",
                  contentData: newReleasesData,
                  carouselType: CarouselType.newReleases,
                  onContentTap: (content) =>
                      Navigator.pushNamed(context, '/content-detail-screen'),
                  onMoreTap: () =>
                      Navigator.pushNamed(context, '/categories-screen'),
                ),
              ),

              SliverToBoxAdapter(child: SizedBox(height: 2.h)),

              SliverToBoxAdapter(
                child: ContentCarouselWidget(
                  title: "Action & Adventure",
                  contentData: actionAdventureData,
                  carouselType: CarouselType.actionAdventure,
                  onContentTap: (content) =>
                      Navigator.pushNamed(context, '/content-detail-screen'),
                  onMoreTap: () =>
                      Navigator.pushNamed(context, '/categories-screen'),
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
        backgroundColor: AppTheme.lightTheme.colorScheme.surface,
        selectedItemColor: AppTheme.lightTheme.primaryColor,
        unselectedItemColor:
        AppTheme.lightTheme.colorScheme.onSurface.withValues(alpha: 0.6),
        elevation: 8,
        items: [
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'home',
              color: _currentBottomNavIndex == 0
                  ? AppTheme.lightTheme.primaryColor
                  : AppTheme.lightTheme.colorScheme.onSurface
                  .withValues(alpha: 0.6),
              size: 24,
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'category',
              color: _currentBottomNavIndex == 1
                  ? AppTheme.lightTheme.primaryColor
                  : AppTheme.lightTheme.colorScheme.onSurface
                  .withValues(alpha: 0.6),
              size: 24,
            ),
            label: 'Categories',
          ),
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'search',
              color: _currentBottomNavIndex == 2
                  ? AppTheme.lightTheme.primaryColor
                  : AppTheme.lightTheme.colorScheme.onSurface
                  .withValues(alpha: 0.6),
              size: 24,
            ),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'person',
              color: _currentBottomNavIndex == 3
                  ? AppTheme.lightTheme.primaryColor
                  : AppTheme.lightTheme.colorScheme.onSurface
                  .withValues(alpha: 0.6),
              size: 24,
            ),
            label: 'Profile',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/categories-screen'),
        backgroundColor: AppTheme.lightTheme.primaryColor,
        child: CustomIconWidget(
          iconName: 'apps',
          color: AppTheme.lightTheme.colorScheme.onPrimary,
          size: 24,
        ),
      ),
    );
  }
}
