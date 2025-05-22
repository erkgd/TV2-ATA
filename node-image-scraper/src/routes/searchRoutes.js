const express = require('express');
const router = express.Router();
const searchController = require('../controllers/searchController');
const { optionalAuthJWT, authenticateJWT } = require('../middlewares/auth');

// Search images (optional auth to save search history)
router.get('/', optionalAuthJWT, searchController.searchImages);

// Get search options (public)
router.get('/options', searchController.getSearchOptions);

// Get search history (protected)
router.get('/history', authenticateJWT, searchController.getSearchHistory);

module.exports = router;
