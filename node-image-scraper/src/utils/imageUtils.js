const axios = require('axios');
const cheerio = require('cheerio');
const sharp = require('sharp');
const fs = require('fs');
const path = require('path');

/**
 * Check if an image has transparency
 * @param {string} imageUrl - URL of the image to check
 * @returns {Promise<boolean>} - Whether the image has transparency
 */
async function isTransparent(imageUrl) {
  try {
    const response = await axios.get(imageUrl, { responseType: 'arraybuffer' });
    const imageBuffer = Buffer.from(response.data, 'binary');
    const metadata = await sharp(imageBuffer).metadata();
    
    return ['rgba', 'png'].includes(metadata.format) && metadata.hasAlpha;
  } catch (error) {
    console.error(`Error checking transparency: ${error.message}`);
    return false;
  }
}

/**
 * Get image metadata like dimensions and file size
 * @param {string} imageUrl - URL of the image
 * @returns {Promise<Object>} - Object containing image metadata
 */
async function getImageMetadata(imageUrl) {
  const metadata = {
    width: null,
    height: null,
    fileSize: null,
    fileType: null,
    isTransparent: false
  };
  
  try {
    // Get file size and type from headers
    const headResponse = await axios.head(imageUrl);
    
    if (headResponse.status === 200) {
      metadata.fileSize = parseInt(headResponse.headers['content-length'] || 0);
      
      // Get file type from Content-Type header
      const contentType = headResponse.headers['content-type'] || '';
      if (contentType.includes('image/')) {
        metadata.fileType = contentType.split('/')[1];
      }
    }
    
    // If file type not determined from headers, try from URL
    if (!metadata.fileType) {
      const urlPath = new URL(imageUrl).pathname.toLowerCase();
      
      if (urlPath.endsWith('.jpg') || urlPath.endsWith('.jpeg')) {
        metadata.fileType = 'jpeg';
      } else if (urlPath.endsWith('.png')) {
        metadata.fileType = 'png';
      } else if (urlPath.endsWith('.gif')) {
        metadata.fileType = 'gif';
      } else if (urlPath.endsWith('.webp')) {
        metadata.fileType = 'webp';
      } else if (urlPath.endsWith('.svg')) {
        metadata.fileType = 'svg';
      }
    }
    
    // Get dimensions by downloading the image
    const response = await axios.get(imageUrl, { responseType: 'arraybuffer' });
    if (response.status === 200) {
      const imageBuffer = Buffer.from(response.data, 'binary');
      const imageMetadata = await sharp(imageBuffer).metadata();
      
      metadata.width = imageMetadata.width;
      metadata.height = imageMetadata.height;
      metadata.isTransparent = imageMetadata.hasAlpha || false;
    }
  } catch (error) {
    console.error(`Error getting image metadata: ${error.message}`);
  }
  
  return metadata;
}

/**
 * Download image and save to public directory
 * @param {string} imageUrl - URL of the image to download
 * @param {string} imageId - ID to use for the saved image
 * @returns {Promise<string>} - Path to the saved image
 */
async function downloadImage(imageUrl, imageId) {
  try {
    const response = await axios.get(imageUrl, { responseType: 'arraybuffer' });
    
    if (response.status === 200) {
      // Determine file extension
      let ext = 'jpg';  // Default extension
      const contentType = response.headers['content-type'] || '';
      
      if (contentType.includes('image/jpeg') || contentType.includes('image/jpg')) {
        ext = 'jpg';
      } else if (contentType.includes('image/png')) {
        ext = 'png';
      } else if (contentType.includes('image/gif')) {
        ext = 'gif';
      } else if (contentType.includes('image/webp')) {
        ext = 'webp';
      } else if (contentType.includes('image/svg+xml')) {
        ext = 'svg';
      }
      
      // Create images directory if it doesn't exist
      const publicDir = path.join(__dirname, '../../public/images');
      if (!fs.existsSync(publicDir)) {
        fs.mkdirSync(publicDir, { recursive: true });
      }
      
      // Save the image
      const imagePath = path.join(publicDir, `${imageId}.${ext}`);
      fs.writeFileSync(imagePath, Buffer.from(response.data, 'binary'));
      
      // Return the public URL path
      return `/public/images/${imageId}.${ext}`;
    }
  } catch (error) {
    console.error(`Error downloading image: ${error.message}`);
  }
  
  return null;
}

/**
 * Get similar images based on title or other properties
 * @param {Object} image - Image object to find similar images for
 * @param {number} limit - Maximum number of similar images to return
 * @returns {Promise<Array>} - Array of similar images
 */
async function getSimilarImages(image, limit = 5) {
  // This would typically use a more sophisticated algorithm
  // For now, just return images with similar titles
  const { Image } = require('../models');
  
  const words = image.title.split(' ').filter(word => word.length > 3);
  
  if (words.length === 0) {
    return [];
  }
  
  // Create a regex to match any of the significant words in the title
  const regex = new RegExp(words.join('|'), 'i');
  
  const similarImages = await Image.find({
    _id: { $ne: image._id },  // Exclude the current image
    title: { $regex: regex }
  })
  .limit(limit)
  .lean();
  
  return similarImages;
}

module.exports = {
  isTransparent,
  getImageMetadata,
  downloadImage,
  getSimilarImages
};
