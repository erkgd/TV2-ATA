# Angular Image Crawler

A modern, responsive image search and collection application built with Angular, TypeScript, and TailwindCSS.

## Features

- 🔍 Advanced image search with multiple filters
- 💾 Save and organize your favorite images
- 👤 User authentication and personal collections
- 💬 Comment and like images
- 📱 Fully responsive design for all devices
- 🌙 Fast and smooth user experience

## Prerequisites

- Node.js (v14 or later)
- npm or yarn
- Angular CLI

## Setup & Installation

1. Clone the repository
   ```bash
   git clone <repository-url>
   cd angular-image-scraper
   ```

2. Install dependencies
   ```bash
   npm install
   ```

3. Configure environment
   - Update `src/environments/environment.ts` with your API endpoint

4. Start development server
   ```bash
   npm start
   ```

5. Build for production
   ```bash
   npm run build
   ```

## Project Structure

```
src/
├── app/
│   ├── components/       # UI components
│   ├── models/           # TypeScript interfaces
│   ├── services/         # API services
│   ├── guards/           # Route guards
│   ├── interceptors/     # HTTP interceptors
│   └── app.module.ts     # Main module
├── assets/               # Static assets
└── environments/         # Environment configuration
```

## API Integration

This Angular application connects to a Node.js backend with Express.js and MongoDB. Make sure the backend API is running and properly configured in the environment files.

## Development

### Code Scaffolding

Generate new components, services, etc. with Angular CLI:

```bash
ng generate component component-name
ng generate service service-name
```

### Running Tests

```bash
# Unit tests
npm run test

# End-to-end tests
npm run e2e
```

## Deployment

1. Build the production-ready application:
   ```bash
   npm run build -- --prod
   ```

2. Deploy the contents of the `dist/angular-image-scraper` directory to your web server.

## Built With

- [Angular](https://angular.io/) - The web framework
- [TailwindCSS](https://tailwindcss.com/) - CSS framework
- [RxJS](https://rxjs.dev/) - Reactive Extensions Library
- [JWT](https://jwt.io/) - JSON Web Tokens for authentication
