class ImageModel {
  final String id;
  final String title;
  final String url;
  final String sourceUrl;
  final String thumbnailUrl;
  final bool isTransparent;
  final String copyrightStatus;
  final int? width;
  final int? height;
  final int? fileSize;
  final String? fileType;
  final String createdAt;
  final int? likesCount;
  final int? commentsCount;
  final bool? userLiked;
  final List<CommentModel>? comments;
  final List<ImageModel>? similarImages;
  final List<LikeModel>? likes;
  final String? source;

  ImageModel({
    required this.id,
    required this.title,
    required this.url,
    required this.sourceUrl,
    required this.thumbnailUrl,
    required this.isTransparent,
    required this.copyrightStatus,
    this.width,
    this.height,
    this.fileSize,
    this.fileType,
    required this.createdAt,
    this.likesCount,
    this.commentsCount,
    this.userLiked,
    this.comments,
    this.similarImages,
    this.likes,
    this.source,
  });
  factory ImageModel.fromJson(Map<String, dynamic> json) {
    // Debug print to see the actual JSON structure
    print('ImageModel.fromJson: ${json.keys.toList()}');
    
    // Make sure we have a valid ID
    if (json['id'] == null && json['_id'] == null) {
      print('Warning: Image JSON has no id field: $json');
    }
    
    // Handle comments safely - ensure it's either a valid list or null
    List<CommentModel>? comments;
    if (json['comments'] != null) {
      try {
        comments = List<CommentModel>.from(
          json['comments'].map((comment) => CommentModel.fromJson(comment)));
      } catch (e) {
        print('Error parsing comments: $e');
        comments = []; // Default to empty list on error
      }
    }
    
    // Handle likes safely - ensure it's either a valid list or null
    List<LikeModel>? likes;
    if (json['likes'] != null) {
      try {
        likes = List<LikeModel>.from(
          json['likes'].map((like) => LikeModel.fromJson(like)));
      } catch (e) {
        print('Error parsing likes: $e');
        likes = []; // Default to empty list on error
      }
    }
    
    // Handle similar images safely
    List<ImageModel>? similarImages;
    if (json['similar_images'] != null || json['similarImages'] != null) {
      try {
        final similarImagesData = json['similar_images'] ?? json['similarImages'];
        similarImages = List<ImageModel>.from(
          similarImagesData.map((image) => ImageModel.fromJson(image)));
      } catch (e) {
        print('Error parsing similar images: $e');
        similarImages = []; // Default to empty list on error
      }
    }    try {
      // Handle integer fields that might come as strings
      int? tryParseWidth() {
        if (json['width'] != null) return int.tryParse(json['width'].toString());
        return null;
      }
      
      int? tryParseHeight() {
        if (json['height'] != null) return int.tryParse(json['height'].toString());
        return null;
      }
      
      int? tryParseFileSize() {
        if (json['file_size'] != null) return int.tryParse(json['file_size'].toString());
        if (json['fileSize'] != null) return int.tryParse(json['fileSize'].toString());
        return null;
      }
      
      int tryParseLikesCount() {
        if (json['likes_count'] != null) return int.tryParse(json['likes_count'].toString()) ?? 0;
        if (json['likesCount'] != null) return int.tryParse(json['likesCount'].toString()) ?? 0;
        return 0;
      }
      
      int tryParseCommentsCount() {
        if (json['comments_count'] != null) return int.tryParse(json['comments_count'].toString()) ?? 0;
        if (json['commentsCount'] != null) return int.tryParse(json['commentsCount'].toString()) ?? 0;
        return 0;
      }
        // Safely extract URLs and apply fallbacks
      String url = json['url'] ?? '';
      if (url.isEmpty || !Uri.tryParse(url)!.isAbsolute) {
        print('Warning: Invalid URL found, using placeholder: $url');
        url = 'https://via.placeholder.com/800x600.png?text=Image+Not+Available';
      }
      
      String thumbnailUrl = json['thumbnail_url'] ?? json['thumbnailUrl'] ?? '';
      if (thumbnailUrl.isEmpty || !Uri.tryParse(thumbnailUrl)!.isAbsolute) {
        print('Warning: Invalid thumbnail URL found, using placeholder: $thumbnailUrl');
        thumbnailUrl = 'https://via.placeholder.com/150x150.png?text=Thumbnail';
      }
      
      return ImageModel(
        id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
        title: json['title'] ?? '',
        url: url,
        sourceUrl: json['source_url'] ?? json['sourceUrl'] ?? '',
        thumbnailUrl: thumbnailUrl,
        isTransparent: json['is_transparent'] ?? json['isTransparent'] ?? false,
        copyrightStatus: json['copyright_status'] ?? json['copyrightStatus'] ?? 'unknown',
        width: tryParseWidth(),
        height: tryParseHeight(),
        fileSize: tryParseFileSize(),
        fileType: json['file_type'] ?? json['fileType'],
        createdAt: json['created_at'] ?? json['createdAt'] ?? '',
        likesCount: tryParseLikesCount(),
        commentsCount: tryParseCommentsCount(),
        userLiked: json['user_liked'] ?? json['userLiked'] ?? false,
        comments: comments,
        similarImages: similarImages,
        likes: likes,
        source: json['source'],
      );
    } catch (e) {
      print('Error in ImageModel.fromJson constructor: $e for JSON: $json');
      // Return a minimal valid ImageModel if there's an error
      return ImageModel(
        id: json['id']?.toString() ?? json['_id']?.toString() ?? 'error-' + DateTime.now().millisecondsSinceEpoch.toString(),
        title: json['title'] ?? 'Error loading image',
        url: json['url'] ?? '',
        sourceUrl: json['source_url'] ?? json['sourceUrl'] ?? '',
        thumbnailUrl: json['thumbnail_url'] ?? json['thumbnailUrl'] ?? '',
        isTransparent: false,
        copyrightStatus: 'unknown',
        createdAt: '',
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'url': url,
      'sourceUrl': sourceUrl,
      'thumbnailUrl': thumbnailUrl,
      'isTransparent': isTransparent,
      'copyrightStatus': copyrightStatus,
      'width': width,
      'height': height,
      'fileSize': fileSize,
      'fileType': fileType,
      'createdAt': createdAt,
      'likesCount': likesCount,
      'commentsCount': commentsCount,
      'userLiked': userLiked,
      'comments': comments?.map((comment) => comment.toJson()).toList(),
      'similarImages': similarImages?.map((image) => image.toJson()).toList(),
      'likes': likes?.map((like) => like.toJson()).toList(),
      'source': source,
    };
  }
}

class LikeModel {
  final String id;
  final String user;
  final String image;
  final String createdAt;

  LikeModel({
    required this.id,
    required this.user,
    required this.image,
    required this.createdAt,
  });

  factory LikeModel.fromJson(Map<String, dynamic> json) {
    return LikeModel(
      id: json['id'] ?? '',
      user: json['user'] ?? '',
      image: json['image'] ?? '',
      createdAt: json['created_at'] ?? json['createdAt'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': user,
      'image': image,
      'createdAt': createdAt,
    };
  }
}

class CommentModel {
  final String id;
  final UserInfo user;
  final String image;
  final String text;
  final String createdAt;

  CommentModel({
    required this.id,
    required this.user,
    required this.image,
    required this.text,
    required this.createdAt,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    // Print debug info
    print('CommentModel.fromJson: ${json}');
    
    // Handle different user formats (string ID or object)
    UserInfo userInfo;
    if (json['user'] is String) {
      // If user is just a string ID
      userInfo = UserInfo(id: json['user'], username: 'User');
    } else if (json['user'] is Map) {
      // If user is an object
      userInfo = UserInfo.fromJson(json['user']);
    } else {
      // Default case - create empty user
      userInfo = UserInfo(id: '', username: 'Unknown User');
    }
    
    return CommentModel(
      id: json['id']?.toString() ?? '',
      user: userInfo,
      image: json['image']?.toString() ?? '',
      text: json['text'] ?? '',
      createdAt: json['created_at'] ?? json['createdAt'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': user.toJson(),
      'image': image,
      'text': text,
      'createdAt': createdAt,
    };
  }
}

class UserInfo {
  final String id;
  final String username;

  UserInfo({
    required this.id,
    required this.username,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      id: json['id'] ?? '',
      username: json['username'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
    };
  }
}