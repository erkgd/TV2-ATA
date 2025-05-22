const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const path = require('path');
const rateLimit = require('express-rate-limit');
require('dotenv').config();

// Import routes
const imageRoutes = require('./routes/imageRoutes');
const userRoutes = require('./routes/userRoutes');
const searchRoutes = require('./routes/searchRoutes');

// Initialize Express app
const app = express();
const PORT = process.env.PORT || 3000;

// Connect to MongoDB (fallback to local if MONGODB_URI not set)
const dbUri = process.env.MONGODB_URI || 'mongodb://localhost:27017/image_crawler';
mongoose.connect(dbUri)
  .then(() => console.log(`MongoDB connected successfully to ${dbUri}`))
  .catch(err => console.error('MongoDB connection error:', err));

// Middleware
app.use(helmet()); // Security headers
app.use(cors()); // Enable CORS for all routes
app.use(express.json()); // Parse JSON bodies
app.use(express.urlencoded({ extended: true })); // Parse URL-encoded bodies
app.use(morgan('dev')); // HTTP request logger

// Rate limiting
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100, // limit each IP to 100 requests per windowMs
  message: 'Too many requests, please try again later.'
});
app.use('/api', limiter);

// Static files
app.use('/public', express.static(path.join(__dirname, '../public')));

app.use('/api/images', imageRoutes);
app.use('/api/users', userRoutes);
app.use('/api/search', searchRoutes);
// Also expose advanced-search at same handlers
app.use('/api/advanced-search', searchRoutes);

// Root route
app.get('/', (req, res) => {
  res.json({
    message: 'Welcome to Node Image Scraper API',
    endpoints: {
      images: '/api/images',
      users: '/api/users',
      search: '/api/search'
    }
  });
});

// Error handling middleware
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(err.status || 500).json({
    message: err.message || 'Internal Server Error',
    error: process.env.NODE_ENV === 'development' ? err : {}
  });
});

// Start server
// Start server only after successful MongoDB connection
mongoose.connection.once('open', () => {
  app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
  });
});
// Handle initial connection errors
mongoose.connection.on('error', err => {
  console.error('MongoDB connection error:', err);
});

module.exports = app;
