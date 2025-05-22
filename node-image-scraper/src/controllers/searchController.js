const { Image, SearchHistory } = require('../models');
const { scrapeGoogleImages } = require('../utils/googleScraper');
const { searchImagesAPI } = require('../utils/apiService');

/**
 * Search images (either from Google or the API)
 */
async function searchImages(req, res) {
  try {
    // Extract query parameters (snake_case)
    const query = req.query.query;
    const copyrightFilter = req.query.copyright_filter;
    const transparentOnly = req.query.transparent_only === 'true';
    const useApi = req.query.use_api === 'true';
    const maxResults = parseInt(req.query.max_results, 10) || 20;
    
    if (!query) {
      return res.status(400).json({ message: 'Search query required' });
    }
    
    console.log(`Processing search request: query=${query}, copyrightFilter=${copyrightFilter}, transparentOnly=${transparentOnly}, useApi=${useApi}`);
    
    // Save search history if user is logged in
    if (req.user) {
      // Save search history
      await SearchHistory.create({
        user: req.user.id,
        query,
        filters: {
          copyright_filter: copyrightFilter || 'unknown',
          transparent_only: transparentOnly,
          use_api: useApi
        }
      });
    }
    
    let images = [];
    
    // Use API or Google Scraper based on preference
    if (useApi) {
      console.log('Using API service for search');
      images = await searchImagesAPI(
        query,
        copyrightFilter,
        transparentOnly,
        maxResults
      );
    } else {
      console.log('Using Google scraper for search');
      images = await scrapeGoogleImages(
        query,
        copyrightFilter,
        transparentOnly === 'true',
        maxResults
      );
    }
    
    console.log(`Found ${images.length} images`);
    
    // Save images to database (could be optimized to avoid duplicates)
    const savedImages = [];
    
    for (const imgData of images) {
      try {
        // Check if image already exists by URL
        let image = await Image.findOne({ url: imgData.url });
        
        if (!image) {
          // Create new image if it doesn't exist
          image = await Image.create({
            title: imgData.title || `Image for: ${query}`,
            url: imgData.url,
            sourceUrl: imgData.sourceUrl,
            thumbnailUrl: imgData.thumbnailUrl,
            width: imgData.width,
            height: imgData.height,
            fileSize: imgData.fileSize,
            fileType: imgData.fileType,
            isTransparent: imgData.isTransparent,
            copyrightStatus: imgData.copyrightStatus
          });
        }
        
        savedImages.push(image);
      } catch (err) {
        console.error(`Error saving image: ${err.message}`);
      }
    }
    
    res.json(savedImages);
  } catch (error) {
    console.error('Error searching images:', error);
    res.status(500).json({ message: 'Internal server error' });
  }
}

/**
 * Get advanced search options
 */
async function getSearchOptions(req, res) {
  // This endpoint returns available search filters
  res.json({
    copyrightOptions: [
      { value: 'free', label: 'Free to use' },
      { value: 'commercial', label: 'Free for commercial use' },
      { value: 'noncommercial', label: 'Free for noncommercial use' },
      { value: 'modification', label: 'Free to modify' },
      { value: 'unknown', label: 'Unknown' }
    ],
    transparencyOptions: [
      { value: true, label: 'Transparent images only' },
      { value: false, label: 'All images' }
    ],
    searchSources: [
      { value: false, label: 'Web search (Google)' },
      { value: true, label: 'API search (Pixabay)' }
    ]
  });
}

/**
 * Get search history for the current user
 */
async function getSearchHistory(req, res) {
  try {
    if (!req.user) {
      return res.status(401).json({ message: 'Authentication required' });
    }
    
    const history = await SearchHistory.find({ user: req.user.id })
      .sort({ createdAt: -1 })
      .limit(20)
      .lean();
    
    res.json(history);
  } catch (error) {
    console.error('Error getting search history:', error);
    res.status(500).json({ message: 'Internal server error' });
  }
}

module.exports = {
  searchImages,
  getSearchOptions,
  getSearchHistory
};
