const axios = require('axios');
const cheerio = require('cheerio');
const { getImageMetadata } = require('./imageUtils');

/**
 * Scrape Google images using a more robust approach
 * @param {string} query - Search query
 * @param {string} copyrightFilter - Copyright filter ('free', 'commercial', etc.)
 * @param {boolean} transparentOnly - Whether to only return transparent images
 * @param {number} maxResults - Maximum number of results to return
 * @returns {Promise<Array>} - Array of image objects
 */
async function scrapeGoogleImages(query, copyrightFilter = null, transparentOnly = false, maxResults = 20) {
  console.log(`Starting Google scraping with query='${query}'`);
  const images = [];
  
  // Build Google Images search URL with filters
  const searchParams = new URLSearchParams({
    q: query,
    tbm: 'isch', // Image search
  });
  
  // Add copyright filter if specified
  if (copyrightFilter) {
    if (copyrightFilter === 'free') {
      searchParams.append('tbs', 'il:cl'); // Creative Commons licenses
    } else if (copyrightFilter === 'commercial') {
      searchParams.append('tbs', 'sur:fc'); // Commercial licenses
    }
  }
  
  // Add transparent filter if specified
  if (transparentOnly) {
    if (searchParams.has('tbs')) {
      const currentTbs = searchParams.get('tbs');
      searchParams.set('tbs', `${currentTbs},ic:trans`); // Transparent images
    } else {
      searchParams.append('tbs', 'ic:trans');
    }
  }
  
  const searchUrl = `https://www.google.com/search?${searchParams.toString()}`;
  console.log(`Search URL: ${searchUrl}`);
  
  const headers = {
    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/121.0.0.0 Safari/537.36',
    'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8',
    'Accept-Language': 'es-ES,es;q=0.9,en-US;q=0.8,en;q=0.7',
    'Referer': 'https://www.google.com/',
    'Connection': 'keep-alive',
    'Sec-Ch-Ua': '"Not A(Brand";v="99", "Google Chrome";v="121", "Chromium";v="121"',
    'Sec-Ch-Ua-Mobile': '?0',
    'Sec-Ch-Ua-Platform': '"Windows"',
    'Sec-Fetch-Dest': 'document',
    'Sec-Fetch-Mode': 'navigate',
    'Sec-Fetch-Site': 'same-origin',
    'Sec-Fetch-User': '?1',
    'Upgrade-Insecure-Requests': '1',
  };
  
  try {
    console.log('Sending request to Google...');
    const response = await axios.get(searchUrl, { headers, timeout: 10000 });
    console.log(`Response received, status code: ${response.status}`);
    
    if (response.status !== 200) {
      console.log(`Error response: ${response.status}`);
      return images;
    }
    
    // Use a more robust strategy to extract image information
    console.log('Analyzing HTML response...');
    
    // Method 1: Find data-src in img tags
    const $ = cheerio.load(response.data);
    $('img').each(function() {
      try {
        const imgSrc = $(this).attr('data-src');
        
        if (imgSrc && !imgSrc.includes('google')) {
          // If we found a valid image URL
          // Try to get the image title
          let title = 'Image for: ' + query;  // Default title
          
          const parentDiv = $(this).closest('div');
          if (parentDiv.length) {
            const titleElem = parentDiv.find('h3');
            if (titleElem.length) {
              title = titleElem.text();
            }
          }
          
          // Create the image object
          const imgData = {
            title,
            url: imgSrc,
            thumbnailUrl: imgSrc,  // Use the same URL as thumbnail
            sourceUrl: searchUrl,  // Default to search URL
            width: null,
            height: null,
            fileSize: null,
            fileType: imgSrc.includes('.jpg') ? 'jpg' : (imgSrc.includes('.png') ? 'png' : 'unknown'),
            copyrightStatus: copyrightFilter || 'unknown',
            isTransparent: transparentOnly
          };
          
          images.push(imgData);
          console.log(`Image found (method 1): ${imgSrc.substring(0, 50)}...`);
          
          if (images.length >= maxResults) {
            return false; // Break out of each loop
          }
        }
      } catch (e) {
        // Ignore errors for individual images
      }
    });
    
    // Method 2: Look for JSON in scripts
    if (images.length < maxResults) {
      console.log('Trying method 2 - JSON search...');
      
      $('script').each(function() {
        const scriptContent = $(this).html();
        
        if (scriptContent && scriptContent.includes('AF_initDataCallback')) {
          try {
            // Try to extract valid JSON blocks
            const matches = scriptContent.match(/(\["https?:\/\/[^"]+?\.(?:jpg|jpeg|png|gif|webp)",[^\]]+\])/g);
            
            if (matches) {
              for (const match of matches) {
                try {
                  const data = JSON.parse('[' + match + ']');
                  
                  if (Array.isArray(data) && data.length > 0) {
                    for (const item of data) {
                      if (Array.isArray(item) && item.length > 0) {
                        // First element is usually the URL
                        for (const element of item) {
                          if (typeof element === 'string' && 
                              element.startsWith('http') && 
                              /\.(jpg|jpeg|png|gif|webp)/.test(element)) {
                            
                            const imgUrl = element;
                            
                            const imgData = {
                              title: `Result for: ${query}`,
                              url: imgUrl,
                              thumbnailUrl: imgUrl,
                              sourceUrl: searchUrl,
                              width: null,
                              height: null,
                              fileSize: null,
                              fileType: imgUrl.includes('.jpg') ? 'jpg' : 
                                      (imgUrl.includes('.png') ? 'png' : 'unknown'),
                              copyrightStatus: copyrightFilter || 'unknown',
                              isTransparent: transparentOnly
                            };
                            
                            // Don't add duplicates
                            if (!images.some(img => img.url === imgUrl)) {
                              images.push(imgData);
                              console.log(`Image found (method 2): ${imgUrl.substring(0, 50)}...`);
                              
                              if (images.length >= maxResults) {
                                return false; // Break out of the loop
                              }
                            }
                          }
                        }
                      }
                    }
                  }
                } catch (e) {
                  // Ignore errors for individual matches
                }
              }
            }
          } catch (e) {
            // Ignore errors for individual scripts
          }
        }
      });
    }
    
    // Method 3: Last resort, look for URLs directly in the HTML
    if (images.length < maxResults) {
      console.log('Trying method 3 - direct URL extraction...');
      
      const imgUrls = response.data.match(/https?:\/\/[^"']+\.(?:jpg|jpeg|png|gif|webp)/g);
      
      if (imgUrls) {
        for (const imgUrl of imgUrls) {
          // Filter out Google URLs and duplicates
          if (!imgUrl.includes('google') && !images.some(img => img.url === imgUrl)) {
            const imgData = {
              title: `Result for: ${query}`,
              url: imgUrl,
              thumbnailUrl: imgUrl,
              sourceUrl: searchUrl,
              width: null,
              height: null,
              fileSize: null,
              fileType: imgUrl.includes('.jpg') ? 'jpg' : 
                      (imgUrl.includes('.png') ? 'png' : 'unknown'),
              copyrightStatus: copyrightFilter || 'unknown',
              isTransparent: transparentOnly
            };
            
            images.push(imgData);
            console.log(`Image found (method 3): ${imgUrl.substring(0, 50)}...`);
            
            if (images.length >= maxResults) {
              break;
            }
          }
        }
      }
    }
    
    console.log(`Scraping completed. Found ${images.length} images.`);
    
    // Try to get metadata for the first few images
    const metadataPromises = images.slice(0, Math.min(5, images.length)).map(async (img, index) => {
      try {
        console.log(`Getting metadata for image ${index + 1}...`);
        const metadata = await getImageMetadata(img.url);
        Object.assign(images[index], metadata);
      } catch (e) {
        console.log(`Error getting metadata for image ${index + 1}: ${e.message}`);
      }
    });
    
    await Promise.allSettled(metadataPromises);
    
  } catch (error) {
    console.error(`Error during scraping: ${error.message}`);
  }
  
  return images.slice(0, maxResults);
}

module.exports = {
  scrapeGoogleImages
};
