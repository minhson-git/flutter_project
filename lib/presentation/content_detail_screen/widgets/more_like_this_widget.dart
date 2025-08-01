import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../models/movie_model.dart';
import '../../../models/playlist_model.dart';
import '../../../services/auth_service.dart';
import '../../../services/playlist_service.dart';
import '../content_detail_screen.dart';

class MoreLikeThisWidget extends StatelessWidget {
  final List<MovieModel> relatedMovies;

  const MoreLikeThisWidget({
    super.key,
    required this.relatedMovies,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 2.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Text(
              "Similar movies",
              style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(height: 2.h),

          // Related Content List
          SizedBox(
            height: 28.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              itemCount: relatedMovies.length,
              separatorBuilder: (context, index) => SizedBox(width: 3.w),
              itemBuilder: (context, index) {
                final movie = relatedMovies[index];
                return _RelatedContentCard(movie: movie);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _RelatedContentCard extends StatelessWidget {
  final MovieModel movie;

  const _RelatedContentCard({required this.movie});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate to movie detail
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ContentDetailScreen(movieId: movie.id),
          ),
        );
      },
      onLongPress: () {
        _showQuickActionsMenu(context);
      },
      child: SizedBox(
        width: 35.w,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Movie Thumbnail
            Container(
              width: 35.w,
              height: 20.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: AppTheme.lightTheme.colorScheme.surface,
              ),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: movie.posterUrl?.isNotEmpty == true
                        ? CustomImageWidget(
                            imageUrl: movie.posterUrl!,
                            width: 35.w,
                            height: 20.h,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            width: 35.w,
                            height: 20.h,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.movie,
                              size: 50,
                              color: Colors.grey,
                            ),
                          ),
                  ),

                  // Rating Badge
                  Positioned(
                    top: 1.h,
                    right: 2.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 2.w,
                        vertical: 0.5.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CustomIconWidget(
                            iconName: 'star',
                            color: Colors.yellow,
                            size: 12,
                          ),
                          SizedBox(width: 1.w),
                          Text(
                            movie.rating.toStringAsFixed(1),
                            style: AppTheme.lightTheme.textTheme.bodySmall
                                ?.copyWith(
                              color: Colors.white,
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Play Overlay
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.black.withValues(alpha: 0.3),
                      ),
                      child: Center(
                        child: Container(
                          width: 12.w,
                          height: 12.w,
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: CustomIconWidget(
                            iconName: 'play_arrow',
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 1.h),

            // Movie Title
            Text(
              movie.title,
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 0.5.h),

            // Year
            Text(
              movie.releaseYear.toString(),
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurface
                    .withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showQuickActionsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.lightTheme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
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
              movie.title,
              style: AppTheme.lightTheme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 3.h),

            // Quick Actions
            _buildQuickAction(
              context,
              "Play",
              "play_arrow",
              () {
                Navigator.pop(context);
                // Handle play action
              },
            ),
            _buildQuickAction(
              context,
              "Add to Watch List",
              "add",
              () {
                Navigator.pop(context);
                _showPlaylistSelection(context);
              },
            ),
            _buildQuickAction(
              context,
              "Share",
              "share",
              () {
                Navigator.pop(context);
                // Handle share action
              },
            ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAction(
    BuildContext context,
    String title,
    String iconName,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: CustomIconWidget(
        iconName: iconName,
        color: AppTheme.lightTheme.colorScheme.onSurface,
        size: 24,
      ),
      title: Text(
        title,
        style: AppTheme.lightTheme.textTheme.bodyMedium,
      ),
      onTap: onTap,
    );
  }

  void _showPlaylistSelection(BuildContext context) async {
    try {
      final currentUserId = AuthService.currentUser?.uid;
      if (currentUserId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please login to use this feature')),
        );
        return;
      }

      // Load user playlists
      final playlists = await PlaylistService.getUserPlaylists(currentUserId);
      
      if (!context.mounted) return;
      
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
                'Add "${movie.title}" to playlist',
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
                  'Create new playlist',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _showCreatePlaylistDialog(context);
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
                          '${playlist.movieCount} movie',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                          ),
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          _addMovieToPlaylist(context, playlist);
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
                        'No playlist yet',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 16.sp,
                        ),
                      ),
                      SizedBox(height: 1.h),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _showCreatePlaylistDialog(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE50914),
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Create your first playlist'),
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
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Playlist download error: $e')),
        );
      }
    }
  }

  void _showCreatePlaylistDialog(BuildContext context) {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    bool isPublic = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: const Color(0xFF1A1A1A),
          title: const Text(
            'Create new playlist',
            style: TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Playlist name *',
                  labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
                  hintText: 'Enter playlist name',
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
                  labelText: 'Description',
                  labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
                  hintText: 'Short description of playlist (optional)',
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
                  'Publish',
                  style: TextStyle(color: Colors.white),
                ),
                subtitle: Text(
                  'Allow others to view this playlist',
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
                'Cancel',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter playlist name')),
                  );
                  return;
                }
                Navigator.pop(context);
                await _createPlaylistAndAddMovie(
                  context,
                  nameController.text.trim(),
                  descriptionController.text.trim(),
                  isPublic,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE50914),
                foregroundColor: Colors.white,
              ),
              child: const Text('Create and Add Movies'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createPlaylistAndAddMovie(
    BuildContext context,
    String name,
    String description,
    bool isPublic,
  ) async {
    try {
      final currentUserId = AuthService.currentUser?.uid;
      if (currentUserId == null) return;

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
      if (movie.id != null) {
        await PlaylistService.addMovieToPlaylist(createdPlaylist, movie.id!);
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Created playlist "$name" and added "${movie.title}"'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Playlist creation error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _addMovieToPlaylist(BuildContext context, PlaylistModel playlist) async {
    try {
      if (movie.id == null || playlist.id == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: Invalid movie or playlist information')),
        );
        return;
      }

      await PlaylistService.addMovieToPlaylist(playlist.id!, movie.id!);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Added "${movie.title}" to "${playlist.name}"'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding to playlist: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
