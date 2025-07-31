import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../core/app_export.dart';
import './edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserModel? _currentUser;
  bool _isLoading = true;
  List<MovieModel> _favoriteMovies = [];
  List<PlaylistModel> _userPlaylists = [];
  List<WatchHistoryModel> _watchHistory = [];
  int _totalWatchTime = 0; // in minutes
  Map<String, MovieModel> _movieCache = {}; // Cache movies for watch history

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    
    try {
      final currentUserId = AuthService.currentUser?.uid;
      if (currentUserId != null) {
        // Load user profile
        _currentUser = await UserService.getUserProfile(currentUserId);
        
        // Load user's playlists
        _userPlaylists = await PlaylistService.getUserPlaylists(currentUserId);
        
        // Load watch history
        _watchHistory = await WatchHistoryService.getUserWatchHistory(currentUserId);
        
        // Calculate total watch time (convert from seconds to minutes)
        _totalWatchTime = _watchHistory.fold(0, (sum, history) => sum + (history.watchDuration ~/ 60));
        
        // Load movie data for watch history
        await _loadMoviesForWatchHistory();
        
        // Load favorite movies
        if (_currentUser != null && _currentUser!.favoriteMovies.isNotEmpty) {
          _favoriteMovies = await MovieService.getMoviesByIds(_currentUser!.favoriteMovies);
        }
        
        print('✅ Loaded user data: ${_currentUser?.username}, ${_userPlaylists.length} playlists, ${_favoriteMovies.length} favorites, ${_watchHistory.length} watch history items');
      }
    } catch (e) {
      print('❌ Error loading user data: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi tải dữ liệu: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _refreshUserData() async {
    await _loadUserData();
  }

  Future<void> _loadMoviesForWatchHistory() async {
    try {
      // Get unique movie IDs from watch history
      final movieIds = _watchHistory.map((h) => h.movieId).toSet().toList();
      
      if (movieIds.isNotEmpty) {
        // Load movies in batches to avoid Firestore limitations
        _movieCache.clear();
        for (int i = 0; i < movieIds.length; i += 10) {
          final batch = movieIds.sublist(i, (i + 10 > movieIds.length) ? movieIds.length : i + 10);
          final movies = await MovieService.getMoviesByIds(batch);
          
          for (final movie in movies) {
            _movieCache[movie.id!] = movie;
          }
        }
      }
    } catch (e) {
      print('❌ Error loading movies for watch history: $e');
    }
  }

  Future<void> _navigateToEditProfile() async {
    if (_currentUser == null) return;
    
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfileScreen(user: _currentUser!),
      ),
    );
    
    // If user data was updated, refresh the profile
    if (result != null && result is UserModel) {
      setState(() {
        _currentUser = result;
      });
    }
  }

  Future<void> _signOut() async {
    try {
      await AuthService.signOut();
      Navigator.pushReplacementNamed(context, AppRoutes.authScreen);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi đăng xuất: $e')),
      );
    }
  }

  void _showCreatePlaylistDialog() {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    bool isPublic = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Tạo playlist mới'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Tên playlist *',
                  hintText: 'Nhập tên playlist',
                ),
              ),
              SizedBox(height: 2.h),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Mô tả',
                  hintText: 'Mô tả ngắn về playlist (tùy chọn)',
                ),
                maxLines: 2,
              ),
              SizedBox(height: 1.h),
              CheckboxListTile(
                title: const Text('Công khai'),
                subtitle: const Text('Cho phép người khác xem playlist này'),
                value: isPublic,
                onChanged: (value) {
                  setDialogState(() {
                    isPublic = value ?? false;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Vui lòng nhập tên playlist')),
                  );
                  return;
                }
                await _createPlaylist(nameController.text.trim(), descriptionController.text.trim(), isPublic);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.lightTheme.primaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Tạo'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createPlaylist(String name, String description, bool isPublic) async {
    try {
      if (_currentUser == null) return;

      final playlist = PlaylistModel(
        userId: _currentUser!.id!,
        name: name,
        description: description,
        isPublic: isPublic,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await PlaylistService.createPlaylist(playlist);
      await _refreshUserData(); // Reload data
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tạo playlist thành công!'),
            backgroundColor: Colors.green,
          ),
        );
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

  void _handlePlaylistAction(String action, PlaylistModel playlist) {
    switch (action) {
      case 'view':
        // TODO: Navigate to playlist detail screen
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Xem playlist: ${playlist.name}')),
        );
        break;
      case 'edit':
        _showEditPlaylistDialog(playlist);
        break;
      case 'share':
        // TODO: Implement share functionality
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Chia sẻ playlist: ${playlist.name}')),
        );
        break;
      case 'delete':
        _showDeletePlaylistDialog(playlist);
        break;
    }
  }

  void _showEditPlaylistDialog(PlaylistModel playlist) {
    final nameController = TextEditingController(text: playlist.name);
    final descriptionController = TextEditingController(text: playlist.description);
    bool isPublic = playlist.isPublic;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Chỉnh sửa playlist'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Tên playlist *',
                ),
              ),
              SizedBox(height: 2.h),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Mô tả',
                ),
                maxLines: 2,
              ),
              SizedBox(height: 1.h),
              CheckboxListTile(
                title: const Text('Công khai'),
                value: isPublic,
                onChanged: (value) {
                  setDialogState(() {
                    isPublic = value ?? false;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Vui lòng nhập tên playlist')),
                  );
                  return;
                }
                await _updatePlaylist(playlist, nameController.text.trim(), descriptionController.text.trim(), isPublic);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.lightTheme.primaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Cập nhật'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updatePlaylist(PlaylistModel playlist, String name, String description, bool isPublic) async {
    try {
      final updatedPlaylist = playlist.copyWith(
        name: name,
        description: description,
        isPublic: isPublic,
        updatedAt: DateTime.now(),
      );

      await PlaylistService.updatePlaylist(updatedPlaylist);
      await _refreshUserData(); // Reload data
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cập nhật playlist thành công!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi cập nhật playlist: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showDeletePlaylistDialog(PlaylistModel playlist) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa playlist'),
        content: Text('Bạn có chắc chắn muốn xóa playlist "${playlist.name}"?\nHành động này không thể hoàn tác.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _deletePlaylist(playlist);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  Future<void> _deletePlaylist(PlaylistModel playlist) async {
    try {
      await PlaylistService.deletePlaylist(playlist.id!);
      await _refreshUserData(); // Reload data
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Xóa playlist thành công!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi xóa playlist: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _removeFromFavorites(MovieModel movie) async {
    try {
      if (_currentUser == null || movie.id == null) return;

      await UserService.removeFromFavorites(_currentUser!.id!, movie.id!);
      
      // Update local state
      setState(() {
        _favoriteMovies.removeWhere((m) => m.id == movie.id);
        _currentUser = _currentUser!.copyWith(
          favoriteMovies: _currentUser!.favoriteMovies.where((id) => id != movie.id).toList(),
        );
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã xóa "${movie.title}" khỏi danh sách yêu thích'),
            action: SnackBarAction(
              label: 'Hoàn tác',
              onPressed: () => _addToFavorites(movie),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi xóa khỏi yêu thích: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _addToFavorites(MovieModel movie) async {
    try {
      if (_currentUser == null || movie.id == null) return;

      await UserService.addToFavorites(_currentUser!.id!, movie.id!);
      
      // Update local state
      setState(() {
        _favoriteMovies.add(movie);
        _currentUser = _currentUser!.copyWith(
          favoriteMovies: [..._currentUser!.favoriteMovies, movie.id!],
        );
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã thêm "${movie.title}" vào danh sách yêu thích'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi thêm vào yêu thích: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF0D0D0D),
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE50914)),
          ),
        ),
      );
    }

    if (_currentUser == null) {
      return Scaffold(
        backgroundColor: const Color(0xFF0D0D0D),
        appBar: AppBar(
          title: const Text('Profile'),
          backgroundColor: const Color(0xFF0D0D0D),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: const Center(
          child: Text(
            'Không tìm thấy thông tin user',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: RefreshIndicator(
        onRefresh: _refreshUserData,
        color: const Color(0xFFE50914),
        backgroundColor: const Color(0xFF1A1A1A),
        child: CustomScrollView(
          slivers: [
            // Custom App Bar with User Info
            SliverAppBar(
              expandedHeight: 30.h,
              floating: false,
              pinned: true,
              backgroundColor: const Color(0xFF0D0D0D),
              foregroundColor: Colors.white,
              elevation: 0,
              flexibleSpace: FlexibleSpaceBar(
                background: _buildProfileHeader(),
              ),
              actions: [
                IconButton(
                  onPressed: _signOut,
                  icon: const Icon(Icons.logout),
                  tooltip: 'Đăng xuất',
                ),
              ],
            ),
            
            // Content
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(4.w),
                child: Column(
                  children: [
                    // Stats Row
                    _buildStatsRow(),
                    
                    SizedBox(height: 3.h),
                    
                    // Favorite Movies Section
                    _buildFavoriteMoviesSection(),
                    
                    SizedBox(height: 3.h),
                    
                    // User Playlists Section
                    _buildPlaylistsSection(),
                    
                    SizedBox(height: 3.h),
                    
                    // Recent Watch History Section
                    _buildRecentWatchHistorySection(),
                    
                    SizedBox(height: 3.h),
                    
                    // Settings Section
                    _buildSettingsSection(),
                    
                    SizedBox(height: 2.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0D0D0D),
            Color(0xFF1A1A1A),
            Color(0xFF2A2A2A),
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(4.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Avatar with glow effect
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFE50914).withValues(alpha: 0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: const Color(0xFFE50914),
                  backgroundImage: _currentUser!.profileImageUrl != null
                    ? NetworkImage(_currentUser!.profileImageUrl!)
                    : null,
                  child: _currentUser!.profileImageUrl == null
                    ? Text(
                        _currentUser!.username[0].toUpperCase(),
                        style: TextStyle(
                          fontSize: 32.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      )
                    : null,
                ),
              ),
              
              SizedBox(height: 2.h),
              
              // User Name
              Text(
                _currentUser!.fullName ?? _currentUser!.username,
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 2.h),
              
              // Edit Profile Button
              ElevatedButton.icon(
                onPressed: _navigateToEditProfile,
                icon: const Icon(Icons.edit, size: 18),
                label: const Text('Chỉnh sửa profile'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: 0.1),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                    side: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.5.h),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserInfoCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 40,
              backgroundColor: AppTheme.lightTheme.primaryColor,
              backgroundImage: _currentUser!.profileImageUrl != null
                ? NetworkImage(_currentUser!.profileImageUrl!)
                : null,
              child: _currentUser!.profileImageUrl == null
                ? Text(
                    _currentUser!.username[0].toUpperCase(),
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  )
                : null,
            ),
            
            SizedBox(width: 4.w),
            
            // User Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _currentUser!.fullName ?? _currentUser!.username,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.lightTheme.colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    '@${_currentUser!.username}',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppTheme.lightTheme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _currentUser!.subscription.toUpperCase(),
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.lightTheme.primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Edit Button
            IconButton(
              onPressed: _navigateToEditProfile,
              icon: Icon(
                Icons.edit,
                color: AppTheme.lightTheme.primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow() {
    // Calculate hours from minutes
    final totalHours = (_totalWatchTime / 60).floor();
    final totalMinutes = _totalWatchTime % 60;
    final watchTimeText = totalHours > 0 
        ? '${totalHours}h ${totalMinutes}m'
        : '${totalMinutes}m';

    return Column(
      children: [
        // First row
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.favorite,
                title: 'Yêu thích',
                value: _currentUser!.favoriteMovies.length.toString(),
                gradient: const LinearGradient(colors: [Color(0xFFFF6B6B), Color(0xFFFF8E8E)]),
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: _buildStatCard(
                icon: Icons.playlist_play,
                title: 'Playlists',
                value: _userPlaylists.length.toString(),
                gradient: const LinearGradient(colors: [Color(0xFF4ECDC4), Color(0xFF44A08D)]),
              ),
            ),
          ],
        ),
        SizedBox(height: 2.h),
        // Second row
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.history,
                title: 'Đã xem',
                value: _watchHistory.length.toString(),
                gradient: const LinearGradient(colors: [Color(0xFF667eea), Color(0xFF764ba2)]),
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: _buildStatCard(
                icon: Icons.access_time,
                title: 'Thời gian',
                value: watchTimeText,
                gradient: const LinearGradient(colors: [Color(0xFFf093fb), Color(0xFFf5576c)]),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Gradient gradient,
  }) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 24),
          SizedBox(height: 1.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.white.withValues(alpha: 0.9),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFavoriteMoviesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Phim yêu thích',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            if (_favoriteMovies.isNotEmpty)
              TextButton(
                onPressed: () {
                  // TODO: Navigate to all favorites
                },
                child: Text(
                  'Xem tất cả',
                  style: TextStyle(color: const Color(0xFFE50914)),
                ),
              ),
          ],
        ),
        SizedBox(height: 2.h),
        _favoriteMovies.isEmpty
          ? Container(
              padding: EdgeInsets.all(6.w),
              width: 450,
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 48,
                    color: Colors.white.withValues(alpha: 0.5),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'Chưa có phim yêu thích nào',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 16.sp,
                    ),
                  ),
                ],
              ),
            )
          : SizedBox(
              height: 25.h,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _favoriteMovies.take(5).length,
                itemBuilder: (context, index) {
                  final movie = _favoriteMovies[index];
                  return Container(
                    width: 35.w,
                    margin: EdgeInsets.only(right: 3.w),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.contentDetailScreen,
                          arguments: movie,
                        );
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: AspectRatio(
                                      aspectRatio: 2/3,
                                      child: CustomImageWidget(
                                        imageUrl: movie.posterUrl ?? '',
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                      ),
                                    ),
                                  ),
                                  // Gradient overlay
                                  Positioned.fill(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            Colors.transparent,
                                            Colors.black.withValues(alpha: 0.7),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  // Remove from favorites button
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: GestureDetector(
                                      onTap: () => _removeFromFavorites(movie),
                                      child: Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withValues(alpha: 0.6),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: const Icon(
                                          Icons.favorite,
                                          color: Color(0xFFE50914),
                                          size: 18,
                                        ),
                                      ),
                                    ),
                                  ),
                                  // Rating
                                  Positioned(
                                    bottom: 8,
                                    right: 8,
                                    child: Container(
                                      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE50914),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.star, color: Colors.white, size: 12),
                                          SizedBox(width: 1.w),
                                          Text(
                                            movie.rating.toStringAsFixed(1),
                                            style: TextStyle(
                                              fontSize: 10.sp,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 1.h),
                          Text(
                            movie.title,
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
      ],
    );
  }

  Widget _buildPlaylistsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Playlists của tôi',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            TextButton.icon(
              onPressed: () {
                _showCreatePlaylistDialog();
              },
              icon: const Icon(Icons.add, color: Color(0xFFE50914)),
              label: Text(
                'Tạo mới',
                style: TextStyle(color: const Color(0xFFE50914)),
              ),
            ),
          ],
        ),
        SizedBox(height: 2.h),
        _userPlaylists.isEmpty
          ? Container(
              padding: EdgeInsets.all(6.w),
              width: 450,
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.playlist_add,
                    size: 48,
                    color: Colors.white.withValues(alpha: 0.5),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'Chưa có playlist nào',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 16.sp,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  ElevatedButton.icon(
                    onPressed: _showCreatePlaylistDialog,
                    icon: const Icon(Icons.add),
                    label: const Text('Tạo playlist đầu tiên'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE50914),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _userPlaylists.length,
              itemBuilder: (context, index) {
                final playlist = _userPlaylists[index];
                final durationHours = (playlist.totalDuration / 60).floor();
                final durationMinutes = playlist.totalDuration % 60;
                final durationText = durationHours > 0 
                    ? '${durationHours}h ${durationMinutes}m'
                    : '${durationMinutes}m';
                
                return Container(
                  margin: EdgeInsets.only(bottom: 2.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                  ),
                  child: ListTile(
                    contentPadding: EdgeInsets.all(3.w),
                    leading: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: playlist.isDefault 
                            ? const LinearGradient(colors: [Color(0xFFFF6B6B), Color(0xFFFF8E8E)])
                            : const LinearGradient(colors: [Color(0xFF667eea), Color(0xFF764ba2)]),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        playlist.isDefault 
                            ? Icons.star
                            : playlist.isPublic 
                                ? Icons.public
                                : Icons.playlist_play,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(
                            playlist.name,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16.sp,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        if (playlist.isPublic)
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                            decoration: BoxDecoration(
                              color: const Color(0xFF4ECDC4),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Công khai',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 0.5.h),
                        Text(
                          '${playlist.movieCount} phim • $durationText',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 14.sp,
                          ),
                        ),
                        if (playlist.description.isNotEmpty)
                          Padding(
                            padding: EdgeInsets.only(top: 0.5.h),
                            child: Text(
                              playlist.description,
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.white.withValues(alpha: 0.6),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        SizedBox(height: 0.5.h),
                        Text(
                          'Cập nhật ${_getTimeAgo(playlist.updatedAt)}',
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: Colors.white.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                    trailing: PopupMenuButton<String>(
                      icon: Icon(
                        Icons.more_vert,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                      color: const Color(0xFF2A2A2A),
                      onSelected: (value) => _handlePlaylistAction(value, playlist),
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'view',
                          child: ListTile(
                            leading: const Icon(Icons.visibility, color: Colors.white),
                            title: const Text('Xem playlist', style: TextStyle(color: Colors.white)),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                        if (!playlist.isDefault)
                          PopupMenuItem(
                            value: 'edit',
                            child: ListTile(
                              leading: const Icon(Icons.edit, color: Colors.white),
                              title: const Text('Chỉnh sửa', style: TextStyle(color: Colors.white)),
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        PopupMenuItem(
                          value: 'share',
                          child: ListTile(
                            leading: const Icon(Icons.share, color: Colors.white),
                            title: const Text('Chia sẻ', style: TextStyle(color: Colors.white)),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                        if (!playlist.isDefault)
                          PopupMenuItem(
                            value: 'delete',
                            child: ListTile(
                              leading: const Icon(Icons.delete, color: Colors.red),
                              title: const Text('Xóa', style: TextStyle(color: Colors.red)),
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                      ],
                    ),
                    onTap: () {
                      // TODO: Navigate to playlist detail
                      _handlePlaylistAction('view', playlist);
                    },
                  ),
                );
              },
            ),
      ],
    );
  }

  Widget _buildRecentWatchHistorySection() {
    final recentHistory = _watchHistory.take(5).toList();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Xem gần đây',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            if (recentHistory.isNotEmpty)
              TextButton(
                onPressed: () {
                  // TODO: Navigate to full watch history
                },
                child: Text(
                  'Xem tất cả',
                  style: TextStyle(color: const Color(0xFFE50914)),
                ),
              ),
          ],
        ),
        recentHistory.isEmpty
          ? Container(
              padding: EdgeInsets.all(6.w),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.history,
                    size: 48,
                    color: Colors.white.withValues(alpha: 0.5),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'Chưa có lịch sử xem nào',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 16.sp,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: recentHistory.length,
              itemBuilder: (context, index) {
                final history = recentHistory[index];
                final movie = _movieCache[history.movieId];
                final timeAgo = _getTimeAgo(history.lastWatchedAt);
                final watchMinutes = (history.watchDuration / 60).round();
                final progressPercentage = history.progressPercentage.round();
                
                return Container(
                  margin: EdgeInsets.only(bottom: 2.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                  ),
                  child: ListTile(
                    contentPadding: EdgeInsets.all(3.w),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: SizedBox(
                        width: 60,
                        height: 60,
                        child: Stack(
                          children: [
                            CustomImageWidget(
                              imageUrl: movie?.posterUrl ?? '',
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                            ),
                            // Progress indicator
                            if (progressPercentage > 0)
                              Positioned(
                                bottom: 0,
                                left: 0,
                                right: 0,
                                child: Container(
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.3),
                                  ),
                                  child: FractionallySizedBox(
                                    alignment: Alignment.centerLeft,
                                    widthFactor: progressPercentage / 100,
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFE50914),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    title: Text(
                      movie?.title ?? 'Phim không tìm thấy',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16.sp,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 0.5.h),
                        Text(
                          'Xem $watchMinutes phút • $progressPercentage%',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 14.sp,
                          ),
                        ),
                        SizedBox(height: 0.5.h),
                        Text(
                          timeAgo,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.white.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (history.isCompleted)
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                            decoration: BoxDecoration(
                              color: const Color(0xFF4ECDC4),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Hoàn thành',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        SizedBox(width: 2.w),
                        Container(
                          padding: EdgeInsets.all(1.w),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE50914),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(
                            Icons.play_arrow,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                    onTap: () {
                      if (movie != null) {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.contentDetailScreen,
                          arguments: movie,
                        );
                      }
                    },
                  ),
                );
              },
            ),
      ],
    );
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} ngày trước';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} giờ trước';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} phút trước';
    } else {
      return 'Vừa xong';
    }
  }

  Widget _buildSettingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '⚙️ Cài đặt',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 2.h),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: Column(
            children: [
              _buildSettingsTile(
                icon: Icons.person,
                title: 'Chỉnh sửa thông tin',
                onTap: _navigateToEditProfile,
              ),
              _buildDivider(),
              _buildSettingsTile(
                icon: Icons.notifications,
                title: 'Thông báo',
                onTap: () {
                  // TODO: Navigate to notifications settings
                },
              ),
              _buildDivider(),
              _buildSettingsTile(
                icon: Icons.security,
                title: 'Bảo mật',
                onTap: () {
                  // TODO: Navigate to security settings
                },
              ),
              _buildDivider(),
              _buildSettingsTile(
                icon: Icons.help,
                title: 'Trợ giúp',
                onTap: () {
                  // TODO: Navigate to help
                },
              ),
              _buildDivider(),
              _buildSettingsTile(
                icon: Icons.logout,
                title: 'Đăng xuất',
                onTap: _signOut,
                isDestructive: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      leading: Container(
        padding: EdgeInsets.all(2.w),
        decoration: BoxDecoration(
          color: isDestructive 
              ? Colors.red.withValues(alpha: 0.1)
              : Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: isDestructive ? Colors.red : Colors.white,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive ? Colors.red : Colors.white,
          fontSize: 16.sp,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: isDestructive 
            ? Colors.red.withValues(alpha: 0.7)
            : Colors.white.withValues(alpha: 0.5),
      ),
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      color: Colors.white.withValues(alpha: 0.1),
      indent: 4.w,
      endIndent: 4.w,
    );
  }
}
