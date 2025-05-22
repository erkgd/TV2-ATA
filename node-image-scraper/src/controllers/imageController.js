const { Image, Like, Comment } = require('../models');
const { downloadImage, getSimilarImages } = require('../utils/imageUtils');

/**
 * Get all images with pagination
 */
async function getAllImages(req, res) {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 20;
    const skip = (page - 1) * limit;
    
    const images = await Image.find()
      .sort({ createdAt: -1 })
      .skip(skip)
      .limit(limit)
      .lean();
    
    const total = await Image.countDocuments();
    
    res.json({
      items: images,
      pagination: {
        total,
        page,
        pages: Math.ceil(total / limit)
      }
    });
  } catch (error) {
    console.error('Error getting images:', error);
    res.status(500).json({ message: 'Internal server error' });
  }
}

/**
 * Get a single image by ID
 */
async function getImageById(req, res) {
  try {
    const { id } = req.params;
    
    const image = await Image.findById(id).lean();
    
    if (!image) {
      return res.status(404).json({ message: 'Image not found' });
    }
    
    // Get likes and comments count
    const likesCount = await Like.countDocuments({ image: id });
    const commentsCount = await Comment.countDocuments({ image: id });
    
    // Get comments for this image
    const comments = await Comment.find({ image: id })
      .populate('user', 'username')
      .sort({ createdAt: -1 })
      .lean();
    
    // Check if the authenticated user has liked this image
    let userLiked = false;
    if (req.user) {
      const userLike = await Like.findOne({ user: req.user.id, image: id });
      userLiked = !!userLike;
    }
    
    // Get similar images
    const similarImages = await getSimilarImages(image, 5);
    
    res.json({
      ...image,
      likesCount,
      commentsCount,
      userLiked,
      comments,
      similarImages
    });
  } catch (error) {
    console.error('Error getting image:', error);
    res.status(500).json({ message: 'Internal server error' });
  }
}

/**
 * Create a new image
 */
async function createImage(req, res) {
  try {
    const imageData = req.body;
    
    // Save the image
    const image = await Image.create(imageData);
    
    // Download the image if needed
    if (image.url) {
      const localPath = await downloadImage(image.url, image._id);
      if (localPath) {
        image.localPath = localPath;
        await image.save();
      }
    }
    
    res.status(201).json(image);
  } catch (error) {
    console.error('Error creating image:', error);
    res.status(500).json({ message: 'Internal server error' });
  }
}

/**
 * Update an image
 */
async function updateImage(req, res) {
  try {
    const { id } = req.params;
    const imageData = req.body;
    
    const image = await Image.findByIdAndUpdate(
      id,
      imageData,
      { new: true, runValidators: true }
    );
    
    if (!image) {
      return res.status(404).json({ message: 'Image not found' });
    }
    
    res.json(image);
  } catch (error) {
    console.error('Error updating image:', error);
    res.status(500).json({ message: 'Internal server error' });
  }
}

/**
 * Delete an image
 */
async function deleteImage(req, res) {
  try {
    const { id } = req.params;
    
    const image = await Image.findByIdAndDelete(id);
    
    if (!image) {
      return res.status(404).json({ message: 'Image not found' });
    }
    
    // Delete related likes and comments
    await Promise.all([
      Like.deleteMany({ image: id }),
      Comment.deleteMany({ image: id })
    ]);
    
    res.json({ message: 'Image deleted successfully' });
  } catch (error) {
    console.error('Error deleting image:', error);
    res.status(500).json({ message: 'Internal server error' });
  }
}

/**
 * Like an image
 */
async function likeImage(req, res) {
  try {
    const { id } = req.params;
    const userId = req.user.id;
    
    // Check if image exists
    const image = await Image.findById(id);
    if (!image) {
      return res.status(404).json({ message: 'Image not found' });
    }
    
    // Check if already liked
    const existingLike = await Like.findOne({ user: userId, image: id });
    
    if (existingLike) {
      // Unlike
      await Like.deleteOne({ _id: existingLike._id });
      res.json({ liked: false });
    } else {
      // Like
      await Like.create({ user: userId, image: id });
      res.json({ liked: true });
    }
  } catch (error) {
    console.error('Error toggling image like:', error);
    res.status(500).json({ message: 'Internal server error' });
  }
}

/**
 * Add a comment to an image
 */
async function addComment(req, res) {
  try {
    const { id } = req.params;
    const { text } = req.body;
    const userId = req.user.id;
    
    if (!text) {
      return res.status(400).json({ message: 'Comment text required' });
    }
    
    // Check if image exists
    const image = await Image.findById(id);
    if (!image) {
      return res.status(404).json({ message: 'Image not found' });
    }
    
    // Create comment
    const comment = await Comment.create({
      user: userId,
      image: id,
      text
    });
    
    // Populate user info
    const populatedComment = await Comment.findById(comment._id)
      .populate('user', 'username')
      .lean();
    
    res.status(201).json(populatedComment);
  } catch (error) {
    console.error('Error adding comment:', error);
    res.status(500).json({ message: 'Internal server error' });
  }
}

module.exports = {
  getAllImages,
  getImageById,
  createImage,
  updateImage,
  deleteImage,
  likeImage,
  addComment
};
