// Export all models from a single file
const Image = require('./image');
const User = require('./user');
const Like = require('./like');
const Comment = require('./comment');
const SearchHistory = require('./searchHistory');

module.exports = {
  Image,
  User,
  Like,
  Comment,
  SearchHistory
};
