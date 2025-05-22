import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/services.dart';
import 'image_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ImageService _imageService = ImageService();
  final SearchService _searchService = SearchService();
  final AuthService _authService = AuthService();
  
  final TextEditingController _searchController = TextEditingController();
  String _copyrightFilter = '';
  bool _transparentOnly = false;
  
  List<ImageModel> _trendingImages = [];
  List<ImageModel> _searchResults = [];
  List<Map<String, dynamic>> _copyrightOptions = [];
  
  bool _isSearching = false;
  bool _isLoading = true;
  bool _searchPerformed = false;
  bool _isLoggedIn = false;
  String? _error;
  
  // Pagination
  int _currentPage = 1;
  int _totalPages = 1;
  int _imagesPerPage = 8;

  @override
  void initState() {
    super.initState();
    _loadSearchOptions();
    _loadTrendingImages();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    final isLoggedIn = await _authService.isLoggedIn();
    setState(() {
      _isLoggedIn = isLoggedIn;
    });
  }

  Future<void> _loadSearchOptions() async {
    try {
      final options = await _searchService.getSearchOptions();
      setState(() {
        _copyrightOptions = (options['categories'] ?? [])
            .map<Map<String, dynamic>>((c) => {'value': c, 'label': c})
            .toList();
      });
    } catch (e) {
      print('Error loading search options: $e');
    }
  }

  Future<void> _loadTrendingImages([int page = 1]) async {
    setState(() {
      _isLoading = true;
      _error = null;
      _currentPage = page;
    });

    try {
      final response = await _imageService.getAllImages(page: page, limit: _imagesPerPage);
      setState(() {
        _trendingImages = response.items;
        _currentPage = response.pagination.page;
        _totalPages = response.pagination.pages;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load trending images. Please try again.';
        _isLoading = false;
      });
      print('Error loading trending images: $e');
    }
  }

  Future<void> _search([int page = 1]) async {
    if (_searchController.text.isEmpty) return;

    setState(() {
      _isSearching = true;
      _error = null;
      _searchPerformed = true;
      _currentPage = page;
    });

    try {
      final response = await _imageService.searchImages(
        _searchController.text,
        copyrightFilter: _copyrightFilter,
        transparentOnly: _transparentOnly,
        page: page,
        limit: _imagesPerPage,
      );

      // Save search to history
      if (page == 1) { // Solo guardamos la primera página en el historial
        _searchService.saveSearchHistory(
          _searchController.text, 
          _copyrightFilter, 
          _transparentOnly
        );
      }

      setState(() {
        // Procesamos los items y la paginación
        final List<dynamic> items = response['items'] as List;
        final Map<String, dynamic> pagination = response['pagination'] as Map<String, dynamic>;
        
        _searchResults = items.map((item) => ImageModel.fromJson(item)).toList();
        _currentPage = pagination['page'] as int;
        _totalPages = pagination['pages'] as int;
        _isSearching = false;
        
        print('Search completed successfully with ${_searchResults.length} results. Page: $_currentPage of $_totalPages'); // Debug
      });
    } catch (e) {
      setState(() {
        _error = 'Search failed. Please try again.';
        _isSearching = false;
      });
      print('Error during search: $e');
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Crawler'),
        elevation: 0,
        actions: [
          // Botón de perfil en el AppBar
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: GestureDetector(
              onTap: () {
                if (_isLoggedIn) {
                  Navigator.of(context).pushNamed('/profile');
                } else {
                  Navigator.of(context).pushNamed('/login');
                }
              },
              child: CircleAvatar(
                backgroundColor: _isLoggedIn ? Colors.blue : Colors.grey,
                child: _isLoggedIn
                    ? const Icon(Icons.person, color: Colors.white)
                    : const Icon(Icons.login, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Card
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [                      Text(
                        'Search for Images',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _searchController,
                        decoration: const InputDecoration(
                          labelText: 'Search Query',
                          border: OutlineInputBorder(),
                          hintText: 'Enter search terms...',
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              decoration: const InputDecoration(
                                labelText: 'Copyright Filter',
                                border: OutlineInputBorder(),
                              ),
                              value: _copyrightFilter.isEmpty ? null : _copyrightFilter,
                              hint: const Text('No filter'),
                              items: [
                                const DropdownMenuItem(
                                  value: '',
                                  child: Text('No filter'),
                                ),
                                ..._copyrightOptions.map((option) => DropdownMenuItem(
                                      value: option['value'],
                                      child: Text(option['label']),
                                    )),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _copyrightFilter = value ?? '';
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: CheckboxListTile(
                              title: const Text('Transparent images only'),
                              value: _transparentOnly,
                              onChanged: (value) {
                                setState(() {
                                  _transparentOnly = value ?? false;
                                });
                              },
                              controlAffinity: ListTileControlAffinity.leading,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton(
                            onPressed: _isSearching ? null : _search,
                            child: _isSearching
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text('Search Images'),
                          ),
                          TextButton(
                            onPressed: () {
                              // Navigate to advanced search
                            },
                            child: const Text('Advanced Search Options'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              if (_error != null)
                Container(
                  margin: const EdgeInsets.only(top: 16),
                  padding: const EdgeInsets.all(16),
                  color: Colors.red[100],
                  child: Text(
                    _error!,
                    style: TextStyle(color: Colors.red[900]),
                  ),
                ),

              // Results section
              if (_searchPerformed) ...[
                const SizedBox(height: 24),
                if (_searchResults.isNotEmpty) ...[                  
                  Text(
                    'Search Results',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  _buildImageGrid(_searchResults),
                  
                  // Pagination controls for search results
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.chevron_left),
                          onPressed: _currentPage > 1
                              ? () => _search(_currentPage - 1)
                              : null,
                        ),
                        Text('Page $_currentPage of $_totalPages'),
                        IconButton(
                          icon: const Icon(Icons.chevron_right),
                          onPressed: _currentPage < _totalPages
                              ? () => _search(_currentPage + 1)
                              : null,
                        ),
                      ],
                    ),
                  ),
                ] else if (!_isSearching) ...[
                  Container(
                    padding: const EdgeInsets.all(32),
                    alignment: Alignment.center,
                    color: Colors.amber[50],
                    child: Column(
                      children: [
                        Text(
                          'No images found',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.amber[800],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Try different search terms or adjust your filters.',
                          style: TextStyle(color: Colors.amber[700]),
                        ),
                      ],
                    ),
                  ),
                ],
              ] else ...[
                // Trending section
                const SizedBox(height: 24),                Text(
                  'Trending Images',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                if (_isLoading)
                  const Center(child: CircularProgressIndicator())
                else
                  _buildImageGrid(_trendingImages),
                
                // Pagination controls
                if (_trendingImages.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.chevron_left),
                          onPressed: _currentPage > 1
                              ? () => _loadTrendingImages(_currentPage - 1)
                              : null,
                        ),
                        Text('Page $_currentPage of $_totalPages'),
                        IconButton(
                          icon: const Icon(Icons.chevron_right),
                          onPressed: _currentPage < _totalPages
                              ? () => _loadTrendingImages(_currentPage + 1)
                              : null,
                        ),
                      ],
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageGrid(List<ImageModel> images) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: images.length,
      itemBuilder: (context, index) {
        final image = images[index];
        return GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => ImageDetailScreen(imageId: image.id),
              ),
            );
          },
          child: Card(
            clipBehavior: Clip.antiAlias,
            elevation: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Image.network(
                    image.thumbnailUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  (loadingProgress.expectedTotalBytes ?? 1)
                              : null,
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(
                        child: Icon(Icons.broken_image, size: 40),
                      );
                    },
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
                        children: [                          Text(
                            '${image.width}x${image.height}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),                          Text(
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
        );
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
