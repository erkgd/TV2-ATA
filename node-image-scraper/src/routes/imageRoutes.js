const express = require('express');
const router = express.Router();
const imageController = require('../controllers/imageController');
const { authenticateJWT, optionalAuthJWT } = require('../middlewares/auth');

// Get all images (public)
router.get('/', imageController.getAllImages);

// Get single image (optional authentication to check if user liked it)
router.get('/:id', optionalAuthJWT, imageController.getImageById);

// Create new image (protected)
router.post('/', authenticateJWT, imageController.createImage);

// Update image (protected)
router.put('/:id', authenticateJWT, imageController.updateImage);

// Delete image (protected)
router.delete('/:id', authenticateJWT, imageController.deleteImage);

// Like/unlike an image (protected)
router.post('/:id/like', authenticateJWT, imageController.likeImage);

// Add comment to an image (protected)
router.post('/:id/comment', authenticateJWT, imageController.addComment);

module.exports = router;
