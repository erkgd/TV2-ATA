import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/services.dart';

class ImageDetailScreen extends StatefulWidget {
  final String imageId;

  const ImageDetailScreen({Key? key, required this.imageId}) : super(key: key);

  @override
  _ImageDetailScreenState createState() => _ImageDetailScreenState();
}

class _ImageDetailScreenState extends State<ImageDetailScreen> {
  final ImageService _imageService = ImageService();
  final AuthService _authService = AuthService();
  
  ImageModel? _image;
  bool _isLoading = true;
  bool _isLoggedIn = false;
  String? _error;
  
  final TextEditingController _commentController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _commentsKey = GlobalKey();
  bool _submittingComment = false;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
    _loadImage();
  }

  Future<void> _checkAuthStatus() async {
    final isLoggedIn = await _authService.isLoggedIn();
    setState(() {
      _isLoggedIn = isLoggedIn;
    });
  }

  Future<void> _loadImage() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final image = await _imageService.getImageById(widget.imageId);
      setState(() {
        _image = image;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load image details. Please try again.';
        _isLoading = false;
      });
      print('Error loading image: $e');
    }
  }

  Future<void> _toggleLike() async {
    if (!_isLoggedIn) {
      // Navigate to login screen
      Navigator.of(context).pushNamed('/login', arguments: {
        'returnRoute': '/image/${widget.imageId}',
      });
      return;
    }

    try {
      final response = await _imageService.likeImage(widget.imageId);
      setState(() {
        if (_image != null) {
          final bool liked = response['liked'] ?? false;
          _image = _image!.copyWith(
            userLiked: liked,
            likesCount: (_image!.likesCount ?? 0) + (liked ? 1 : -1),
          );
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update like status: $e')),
      );
    }
  }  Future<void> _submitComment() async {
    if (_commentController.text.trim().isEmpty) return;

    if (!_isLoggedIn) {
      // Navigate to login screen
      Navigator.of(context).pushNamed('/login', arguments: {
        'returnRoute': '/image/${widget.imageId}',
      });
      return;
    }

    setState(() {
      _submittingComment = true;
    });

    try {
      final comment = await _imageService.addComment(
        widget.imageId,
        _commentController.text.trim(),
      );
      
      if (mounted) {
        setState(() {
          _submittingComment = false;
          _commentController.clear();
          
          if (_image != null) {
            final List<CommentModel> updatedComments = [
              ..._image!.comments ?? [],
              comment,
            ];
            _image = _image!.copyWith(
              comments: updatedComments,
              commentsCount: updatedComments.length,
            );
          }
        });        // Add a slight delay to allow the UI to update
        Future.delayed(Duration(milliseconds: 100), () {
          if (mounted) {
            // Scroll to the comments section
            Scrollable.ensureVisible(
              _commentsKey.currentContext!,
              duration: Duration(milliseconds: 300),
              curve: Curves.easeOut,
              alignment: 0.5, // Align in the middle of the viewport
            );
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _submittingComment = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add comment: $e')),
        );
        print('Error adding comment: $e');
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_image?.title ?? 'Image Details'),
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _error!,
                          style: TextStyle(color: Colors.red[700]),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadImage,
                          child: const Text('Try Again'),
                        ),
                      ],
                    ),
                  ),
                )
              : _buildImageDetails(),
    );
  }

  Widget _buildImageDetails() {
    if (_image == null) return const SizedBox.shrink();    return SingleChildScrollView(
      controller: _scrollController,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [          // Image Container
          Container(
            color: Colors.grey[200],
            width: double.infinity,
            constraints: const BoxConstraints(maxHeight: 400),
            child: Image.network(
              _image!.url,
              fit: BoxFit.contain,
              // Add cacheWidth and retry options for better performance
              cacheWidth: 1200,
              frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                if (wasSynchronouslyLoaded || frame != null) {
                  return child;
                }
                return AnimatedOpacity(
                  opacity: frame != null ? 1 : 0,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                  child: child,
                );
              },
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                (loadingProgress.expectedTotalBytes ?? 1)
                            : null,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Loading image...',
                        style: TextStyle(color: Colors.grey[700]),
                      )
                    ],
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                print('Error loading image: $error');
                print('Image URL: ${_image!.url}');
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.broken_image, size: 80, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(
                        'Unable to load image',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.red[700],
                        ),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                        onPressed: _loadImage,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Image Actions
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    // Like Button
                    InkWell(
                      onTap: _toggleLike,
                      child: Row(
                        children: [
                          Icon(
                            _image!.userLiked ?? false
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: _image!.userLiked ?? false ? Colors.red : null,
                          ),
                          const SizedBox(width: 4),
                          Text('${_image!.likesCount ?? 0}'),
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),
                    // Comments Count
                    Row(
                      children: [
                        const Icon(Icons.comment),
                        const SizedBox(width: 4),
                        Text('${_image!.commentsCount ?? 0}'),
                      ],
                    ),
                  ],
                ),
                // Download Button
                ElevatedButton.icon(
                  icon: const Icon(Icons.download),
                  label: const Text('Download'),                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  onPressed: () {
                    // Handle download functionality
                    // In a real app, you'd implement a proper download function
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Download functionality to be implemented')),
                    );
                  },
                ),
              ],
            ),
          ),

          // Source Link
          if (_image!.sourceUrl.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextButton.icon(
                icon: const Icon(Icons.link),
                label: const Text('View original source'),
                onPressed: () {
                  // In a real app, you would open the URL in a web browser
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Source URL: ${_image!.sourceUrl}')),
                  );
                },
              ),
            ),

          const Divider(),

          // Image Information
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [                Text(
                  'Image Information',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                _buildInfoRow('Dimensions',
                    '${_image!.width ?? 'Unknown'} × ${_image!.height ?? 'Unknown'} px'),
                _buildInfoRow('File Type', _image!.fileType ?? 'Unknown'),
                _buildInfoRow(
                    'File Size',
                    _image!.fileSize != null
                        ? '${(_image!.fileSize! / 1024).toStringAsFixed(2)} KB'
                        : 'Unknown'),
                _buildInfoRow('Transparency',
                    _image!.isTransparent ? 'Yes' : 'No'),
                _buildInfoRow('Copyright', _getCopyrightLabel(_image!.copyrightStatus)),
              ],
            ),
          ),

          const Divider(),          // Comments Section
          Padding(
            key: _commentsKey,
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [                Text(
                  'Comments',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                // Add Comment Form
                if (_isLoggedIn) ...[
                  TextField(
                    controller: _commentController,
                    decoration: const InputDecoration(
                      hintText: 'Add a comment...',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: _submittingComment ? null : _submitComment,
                      child: _submittingComment
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Post Comment'),
                    ),
                  ),
                ] else
                  OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed('/login', arguments: {
                        'returnRoute': '/image/${widget.imageId}',
                      });
                    },
                    child: const Text('Log in to comment'),
                  ),
                const SizedBox(height: 16),                // Comments List
                if (_image!.comments != null && _image!.comments!.isNotEmpty)
                  AnimatedList(
                    key: GlobalKey<AnimatedListState>(),
                    initialItemCount: _image!.comments!.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index, animation) {
                      final comment = _image!.comments![index];
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: animation.drive(
                            Tween<Offset>(
                              begin: const Offset(0, 0.5),
                              end: Offset.zero,
                            ).chain(CurveTween(curve: Curves.easeOut))
                          ),
                          child: Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        comment.user.username,
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        _formatDate(comment.createdAt),
                                        style: Theme.of(context).textTheme.bodySmall,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(comment.text),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  )
                else
                  const Center(
                    child: Text(
                      'No comments yet',
                      style: TextStyle(fontStyle: FontStyle.italic),
                    ),
                  ),
              ],
            ),
          ),

          // Similar Images Section
          if (_image!.similarImages != null && _image!.similarImages!.isNotEmpty) ...[
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [                  Text(
                    'Similar Images',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 150,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _image!.similarImages!.length,
                      itemBuilder: (context, index) {
                        final similarImage = _image!.similarImages![index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (context) => ImageDetailScreen(imageId: similarImage.id),
                              ),
                            );
                          },
                          child: Container(
                            width: 150,
                            margin: const EdgeInsets.only(right: 8),
                            child: Column(
                              children: [                                Expanded(
                                  child: Image.network(
                                    similarImage.thumbnailUrl,
                                    fit: BoxFit.cover,
                                    width: 150,
                                    cacheWidth: 300,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        color: Colors.grey[200],
                                        child: const Center(
                                          child: Icon(Icons.broken_image, size: 40),
                                        ),
                                      );
                                    },
                                    loadingBuilder: (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Container(
                                        color: Colors.grey[200],
                                        child: Center(
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            value: loadingProgress.expectedTotalBytes != null
                                                ? loadingProgress.cumulativeBytesLoaded /
                                                    (loadingProgress.expectedTotalBytes ?? 1)
                                                : null,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  similarImage.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
          
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  String _getCopyrightLabel(String status) {
    switch (status.toLowerCase()) {
      case 'free':
        return 'Free to use';
      case 'commercial':
        return 'Commercial use allowed';
      case 'noncommercial':
        return 'Non-commercial use only';
      case 'modification':
        return 'Modifications allowed';
      default:
        return 'Unknown';
    }
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateStr;
    }
  }
  @override
  void dispose() {
    _commentController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

// Extension to create a copy of an image with modified properties
extension ImageCopyWith on ImageModel {
  ImageModel copyWith({
    String? id,
    String? title,
    String? url,
    String? sourceUrl,
    String? thumbnailUrl,
    bool? isTransparent,
    String? copyrightStatus,
    int? width,
    int? height,
    int? fileSize,
    String? fileType,
    String? createdAt,
    int? likesCount,
    int? commentsCount,
    bool? userLiked,
    List<CommentModel>? comments,
    List<ImageModel>? similarImages,
    List<LikeModel>? likes,
    String? source,
  }) {
    return ImageModel(
      id: id ?? this.id,
      title: title ?? this.title,
      url: url ?? this.url,
      sourceUrl: sourceUrl ?? this.sourceUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      isTransparent: isTransparent ?? this.isTransparent,
      copyrightStatus: copyrightStatus ?? this.copyrightStatus,
      width: width ?? this.width,
      height: height ?? this.height,
      fileSize: fileSize ?? this.fileSize,
      fileType: fileType ?? this.fileType,
      createdAt: createdAt ?? this.createdAt,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      userLiked: userLiked ?? this.userLiked,
      comments: comments ?? this.comments,
      similarImages: similarImages ?? this.similarImages,
      likes: likes ?? this.likes,
      source: source ?? this.source,
    );
  }
}
