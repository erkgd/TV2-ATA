const mongoose = require('mongoose');
const Schema = mongoose.Schema;

const likeSchema = new Schema({
  user: {
    type: Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  image: {
    type: Schema.Types.ObjectId,
    ref: 'Image',
    required: true
  },
  createdAt: {
    type: Date,
    default: Date.now
  }
});

// Ensure a user can only like an image once
likeSchema.index({ user: 1, image: 1 }, { unique: true });

const Like = mongoose.model('Like', likeSchema);

module.exports = Like;
