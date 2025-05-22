const { User } = require('../models');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
require('dotenv').config();

const JWT_SECRET = process.env.JWT_SECRET || 'your_jwt_secret_key';

/**
 * Register a new user
 */
async function register(req, res) {
  try {
    const { username, password } = req.body;
    
    if (!username || !password) {
      return res.status(400).json({ message: 'Username and password required' });
    }
    
    // Check if user already exists
    const existingUser = await User.findOne({ username });
    if (existingUser) {
      return res.status(400).json({ message: 'Username already taken' });
    }
    
    // Hash the password
    const saltRounds = 10;
    const hashedPassword = await bcrypt.hash(password, saltRounds);
    
    // Create the user
    const user = await User.create({
      username,
      password: hashedPassword
    });
    
    // Generate JWT token
    const token = jwt.sign(
      { id: user._id, username: user.username },
      JWT_SECRET,
      { expiresIn: '24h' }
    );
    
    res.status(201).json({
      id: user._id,
      username: user.username,
      token
    });
  } catch (error) {
    console.error('Error registering user:', error);
    res.status(500).json({ message: 'Internal server error' });
  }
}

/**
 * Login a user
 */
async function login(req, res) {
  try {
    const { username, password } = req.body;
    
    if (!username || !password) {
      return res.status(400).json({
        detail: 'Username and password required.',
        error_type: 'credentials_missing'
      });
    }
    
    // Find the user
    const user = await User.findOne({ username });
    if (!user) {
      // Username does not exist
      return res.status(400).json({
        detail: 'Invalid credentials',
        username_exists: false,
        error_type: 'authentication_failed'
      });
    }
    
    // Check password
    const passwordMatch = await bcrypt.compare(password, user.password);
    if (!passwordMatch) {
      // Wrong password for existing user
      return res.status(400).json({
        detail: 'Invalid credentials',
        username_exists: true,
        error_type: 'authentication_failed'
      });
    }
    
    // Generate JWT token
    const token = jwt.sign(
      { id: user._id, username: user.username },
      JWT_SECRET,
      { expiresIn: '24h' }
    );
    
    res.json({
      id: user._id,
      username: user.username,
      token
    });
  } catch (error) {
    console.error('Error logging in user:', error);
    res.status(500).json({ message: 'Internal server error' });
  }
}

/**
 * Get user profile
 */
async function getProfile(req, res) {
  try {
    const userId = req.user.id;
    
    // Find the user
    const user = await User.findById(userId);
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }
    
    // Get user's likes, comments, and search history
    const { Like, Comment, SearchHistory } = require('../models');
    
    // Get liked images
    const likes = await Like.find({ user: userId }).populate('image');
    const likedImages = likes.map(like => like.image);
    
    // Get user comments
    const comments = await Comment.find({ user: userId }).populate('image');
    
    // Get search history
    const searchHistory = await SearchHistory.find({ user: userId });
    
    res.json({
      user: {
        id: user._id,
        username: user.username
      },
      liked_images: likedImages,
      comments: comments,
      search_history: searchHistory
    });
  } catch (error) {
    console.error('Error getting user profile:', error);
    res.status(500).json({ message: 'Internal server error' });
  }
}
/**
 * Get basic user info (id & username)
 */
async function getUserInfo(req, res) {
  try {
    res.json({ id: req.user.id, username: req.user.username });
  } catch (error) {
    console.error('Error getting user info:', error);
    res.status(500).json({ message: 'Internal server error' });
  }
}

module.exports = {
  register,
  login,
  getProfile,
  getUserInfo
};
