const mongoose = require('mongoose');
const Schema = mongoose.Schema;

const imageSchema = new Schema({
  title: { 
    type: String, 
    required: true 
  },
  url: { 
    type: String, 
    required: true 
  },
  sourceUrl: { 
    type: String, 
    required: true 
  },
  thumbnailUrl: { 
    type: String, 
    required: true 
  },
  isTransparent: { 
    type: Boolean, 
    default: false 
  },
  copyrightStatus: { 
    type: String, 
    enum: ['free', 'commercial', 'noncommercial', 'modification', 'unknown'], 
    default: 'unknown' 
  },
  width: { 
    type: Number 
  },
  height: { 
    type: Number 
  },
  fileSize: { 
    type: Number 
  },
  fileType: { 
    type: String 
  },
  createdAt: { 
    type: Date, 
    default: Date.now 
  }
});

// Virtual for likes count
imageSchema.virtual('likesCount', {
  ref: 'Like',
  localField: '_id',
  foreignField: 'image',
  count: true
});

// Virtual for comments count
imageSchema.virtual('commentsCount', {
  ref: 'Comment',
  localField: '_id',
  foreignField: 'image',
  count: true
});

const Image = mongoose.model('Image', imageSchema);

module.exports = Image;
