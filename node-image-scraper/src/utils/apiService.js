const axios = require('axios');
require('dotenv').config();

// You should get your own API key from https://pixabay.com/api/docs/
const PIXABAY_API_KEY = process.env.PIXABAY_API_KEY || "YOUR_PIXABAY_API_KEY_HERE";

/**
 * Search for images using Pixabay API instead of scraping Google
 * @param {string} query - Search query
 * @param {string} copyrightFilter - Copyright filter ('free', 'commercial', etc.)
 * @param {boolean} transparentOnly - Whether to only return transparent images
 * @param {number} maxResults - Maximum number of results to return
 * @returns {Promise<Array>} - Array of image objects
 */
async function searchImagesAPI(query, copyrightFilter = null, transparentOnly = false, maxResults = 20) {
  console.log(`Starting API search with query='${query}', copyright_filter='${copyrightFilter}', transparent_only=${transparentOnly}`);
  const images = [];
  
  // Configure Pixabay API parameters
  const searchParams = new URLSearchParams({
    key: PIXABAY_API_KEY,
    q: query,
    per_page: maxResults
  });
  
  // Apply filters
  if (transparentOnly) {
    searchParams.append("image_type", "transparent");
  }
  
  // Set copyright filter (Pixabay has different options)
  if (copyrightFilter) {
    // All Pixabay images are free for commercial use with attribution
    // But we can still map our filter categories
    if (['free', 'commercial', 'modification'].includes(copyrightFilter)) {
      searchParams.append("safesearch", "true");
    }
  }
  
  const apiUrl = "https://pixabay.com/api/";
  
  console.log(`API URL (without key): ${apiUrl}?${new URLSearchParams({
    ...Object.fromEntries(searchParams),
    key: '[REDACTED]'
  }).toString()}`);
  
  try {
    // Make the API request
    const response = await axios.get(apiUrl, { params: Object.fromEntries(searchParams) });
    console.log(`API Response status code: ${response.status}`);
    
    if (response.status === 200) {
      const data = response.data;
      console.log(`API returned ${data.hits?.length || 0} results`);
      
      // Process each image
      for (const item of data.hits || []) {
        const imgData = {
          title: item.tags?.split(",")[0] || "Untitled Image",
          url: item.largeImageURL,
          sourceUrl: item.pageURL,
          thumbnailUrl: item.previewURL,
          width: item.imageWidth,
          height: item.imageHeight,
          fileSize: null, // Pixabay doesn't provide file size
          fileType: "jpg", // Default to jpg, could parse from URL
          isTransparent: transparentOnly,
          copyrightStatus: copyrightFilter || "free" // All Pixabay images are free to use
        };
        
        images.push(imgData);
        
        // For debugging, just show the first one
        if (images.length === 1) {
          console.log(`First image data: ${JSON.stringify(imgData)}`);
        }
      }
    } else {
      console.log(`API error response: ${response.statusText}`);
    }
  } catch (error) {
    console.error(`Exception in API call: ${error.message}`);
  }
  
  return images;
}

/**
 * Search for images using Pexels API
 * @param {string} query - Search query
 * @param {number} maxResults - Maximum number of results to return
 * @returns {Promise<Array>} - Array of image objects
 */
async function searchImagesPexels(query, maxResults = 20) {
  // Pexels API documentation: https://www.pexels.com/api/documentation/
  const API_KEY = "YOUR_PEXELS_API_KEY_HERE"; // Replace with your API key
  
  const headers = {
    Authorization: API_KEY
  };
  
  const searchUrl = `https://api.pexels.com/v1/search?query=${encodeURIComponent(query)}&per_page=${maxResults}`;
  
  try {
    const response = await axios.get(searchUrl, { headers });
    
    if (response.status === 200) {
      const data = response.data;
      const images = [];
      
      for (const photo of data.photos || []) {
        const imgData = {
          title: photo.alt || `Image result for ${query}`,
          url: photo.src.original,
          sourceUrl: photo.url,
          thumbnailUrl: photo.src.medium,
          width: photo.width,
          height: photo.height,
          fileSize: null,
          fileType: 'jpg',
          isTransparent: false,
          copyrightStatus: 'free' // Pexels images are free to use
        };
        
        images.push(imgData);
      }
      
      return images;
    }
  } catch (error) {
    console.error(`Error searching images from Pexels API: ${error.message}`);
  }
  
  return [];
}

module.exports = {
  searchImagesAPI,
  searchImagesPexels
};
