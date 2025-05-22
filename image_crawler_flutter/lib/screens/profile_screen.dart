import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/services.dart';
import 'image_detail_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  final ImageService _imageService = ImageService();
  
  UserModel? _user;
  List<ImageModel> _favoriteImages = [];
    final Map<String, bool> _loading = {
    'user': true,
    'favorites': true,
  };
  
  final Map<String, String?> _error = {
    'user': null,
    'favorites': null,
  };
  
  @override
  void initState() {
    super.initState();
    _loadUserProfile();
    _loadFavoriteImages();
  }
  Future<void> _loadUserProfile() async {
    try {
      print('ProfileScreen: Loading user profile');
      final user = await _authService.getCurrentUser();
      
      print('ProfileScreen: User loaded - Username: ${user.username}, ID: ${user.id}');
      
      setState(() {
        _user = user;
        _loading['user'] = false;
        _error['user'] = null; // Clear any previous errors
      });
    } catch (e) {
      print('ProfileScreen: Error loading profile: $e');
      
      // Try to load a minimal profile with just username if the full profile failed
      try {
        print('ProfileScreen: Attempting fallback to minimal profile');
        final token = await _authService.getToken();
        if (token != null) {
          setState(() {
            _user = UserModel(
              id: 'unknown',
              username: 'User', // Minimal info
              createdAt: DateTime.now().toString(),
            );
            _loading['user'] = false;
          });
          return;
        }
      } catch (fallbackError) {
        print('ProfileScreen: Fallback also failed: $fallbackError');
      }
      
      setState(() {
        _error['user'] = 'Failed to load profile information. Please try again.';
        _loading['user'] = false;
      });
    }
  }
  Future<void> _loadFavoriteImages() async {
    try {
      print('Profile: Loading favorite images'); // Debug logging
      final favorites = await _imageService.getUserFavorites();
      print('Profile: Received ${favorites.length} favorite images'); // Debug logging
      
      setState(() {
        _favoriteImages = favorites;
        _loading['favorites'] = false;
        _error['favorites'] = null; // Clear any previous errors
      });
      
      // Debug logging for the received data
      if (favorites.isNotEmpty) {
        print('Profile: First image title: ${favorites.first.title}, URL: ${favorites.first.url}');
      }
    } catch (e) {
      print('Profile: Error loading favorites: $e'); // Enhanced error logging
      
      // Better error message with more details
      final String errorMessage = e.toString().contains('Failed to parse')
          ? 'Error processing favorite images data. Technical details: $e'
          : 'Failed to load your favorite images. Please try again.';
      
      setState(() {
        _error['favorites'] = errorMessage;
        _loading['favorites'] = false;
        _favoriteImages = []; // Reset to empty list on error
      });
    }
  }

  Future<void> _removeFromFavorites(String imageId) async {
    try {
      await _imageService.unlikeImage(imageId);
      setState(() {
        _favoriteImages = _favoriteImages.where((img) => img.id != imageId).toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to remove from favorites: $e')),
      );
      print('Error removing from favorites: $e');
    }
  }

  Future<void> _logout() async {
    await _authService.logout();
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Profile Card
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),                child: _loading['user'] == true
                    ? const Center(child: CircularProgressIndicator())
                    : _error['user'] != null
                        ? _buildErrorSection(_error['user']!)
                        : _buildUserProfileSection(),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Favorite Images Section
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [                    Text(
                      'Your Favorite Images',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    _loading['favorites'] == true
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(32.0),
                              child: CircularProgressIndicator(),
                            ),
                          )
                        : _error['favorites'] != null
                            ? _buildErrorSection(_error['favorites']!)
                            : _favoriteImages.isEmpty
                                ? const Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(32.0),
                                      child: Text(
                                        'You have not liked any images yet',
                                        style: TextStyle(fontStyle: FontStyle.italic),
                                      ),
                                    ),
                                  )
                                : _buildFavoriteImagesGrid(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserProfileSection() {
    if (_user == null) return const SizedBox.shrink();
    
    return Row(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: Theme.of(context).primaryColor,
          child: Text(
            _user!.username[0].toUpperCase(),
            style: const TextStyle(fontSize: 32, color: Colors.white),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _user!.username,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              if (_user!.email != null)
                Text(
                  _user!.email!,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              if (_user!.createdAt != null)
                Text(
                  'Member since: ${_formatDate(_user!.createdAt!)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFavoriteImagesGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: _favoriteImages.length,
      itemBuilder: (context, index) {
        final image = _favoriteImages[index];
        return Stack(
          fit: StackFit.expand,
          children: [
            Card(
              clipBehavior: Clip.antiAlias,
              elevation: 2,
              child: InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ImageDetailScreen(imageId: image.id),
                    ),
                  );
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Image.network(
                        image.thumbnailUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            image.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${image.width}x${image.height}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              Text(
                                image.fileType ?? '',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 4,
              right: 4,
              child: Container(                decoration: BoxDecoration(
                  color: Colors.black.withAlpha(179), // 0.7 opacity = 179 alpha
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.favorite,
                    color: Colors.white,
                    size: 16,
                  ),
                  tooltip: 'Remove from favorites',
                  onPressed: () => _removeFromFavorites(image.id),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildErrorSection(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.red[700],
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.red[700]),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                _loadUserProfile();
                _loadFavoriteImages();
              },
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateStr;
    }
  }
}
