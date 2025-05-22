const express = require('express');
const router = express.Router();
const { register, login, getProfile, getUserInfo } = require('../controllers/userController');
const { authenticateJWT } = require('../middlewares/auth');

// User registration
router.post('/register', register);

// User login
router.post('/login', login);

// Get basic user info (id & username)
router.get('/me', authenticateJWT, getUserInfo);
// Get full profile (liked images, comments, history)
router.get('/profile', authenticateJWT, getProfile);

module.exports = router;
