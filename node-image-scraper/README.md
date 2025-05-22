# Node Image Scraper

A Node.js version of the Django Image Scraper back-end, providing REST API endpoints for image scraping and management.

## Features

- Image scraping from Google Images
- Alternative API-based image search using Pixabay
- User authentication with JWT
- Image liking and commenting
- Search history tracking
- Image metadata extraction

## API Endpoints

### Authentication

- `POST /api/users/register` - Register a new user
- `POST /api/users/login` - Login and get JWT token
- `GET /api/users/profile` - Get user profile with likes, comments, and search history

### Images

- `GET /api/images` - Get all images with pagination
- `GET /api/images/:id` - Get single image details
- `POST /api/images` - Create a new image
- `PUT /api/images/:id` - Update an image
- `DELETE /api/images/:id` - Delete an image
- `POST /api/images/:id/like` - Like/unlike an image
- `POST /api/images/:id/comment` - Add a comment to an image

### Search

- `GET /api/search` - Search for images with filters
- `GET /api/search/options` - Get search options (filters)
- `GET /api/search/history` - Get user's search history

## Installation

1. Clone the repository
2. Install dependencies:
   ```
   npm install
   ```
3. Set up MongoDB (locally or MongoDB Atlas)
4. Create a `.env` file with the following variables:
   ```
   PORT=3000
   MONGODB_URI=mongodb://localhost:27017/image_scraper
   JWT_SECRET=your_jwt_secret_key
   PIXABAY_API_KEY=your_pixabay_api_key_here
   ```

## Running the Application

### Development mode
```
npm run dev
```

### Production mode
```
npm start
```

## Technologies Used

- Express.js - Web framework
- Mongoose - MongoDB object modeling
- JWT - Authentication
- Axios - HTTP client
- Cheerio - HTML parsing for web scraping
- Sharp - Image processing
- Bcrypt - Password hashing

## License

ISC
