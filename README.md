# Image Crawler Project Suite

## Overview

This repository contains four different implementations of an Image Crawler application, each developed with different technologies to demonstrate various approaches to solving the same problem. The project suite includes:

1. **Django Image Scraper**: A full-stack web application built with Django
2. **Angular Image Scraper**: A modern frontend application built with Angular
3. **Node Image Scraper**: A REST API service built with Node.js
4. **Flutter Image Crawler**: A cross-platform mobile application

All implementations provide similar core functionalities but showcase different architectures and technology stacks.

## Core Features Across All Platforms

- 🔍 **Advanced image search** with multiple filters
- 🖼️ **Image discovery** from various sources
- 👤 **User authentication** and profile management
- 💾 **Save and organize** favorite images
- 💬 **Social interactions** - comments and likes
- 📊 **Search history** tracking

## Project Structure

```
image-crawler/
├── angular-image-scraper/   # Angular frontend
├── django-image-scraper/    # Django full-stack web app
├── node-image-scraper/      # Node.js API backend
└── image_crawler_flutter/   # Flutter mobile app
```

## Applications

### 1. Django Image Scraper

A full-stack web application built with Django, providing both backend and frontend functionality.

**Technologies:**
- Django & Django REST Framework
- SQLite/PostgreSQL
- Tailwind CSS
- Docker support

**Key Features:**
- Google Images scraping with filters
- User authentication and profiles
- Image liking and commenting
- Image metadata extraction
- Responsive web interface

**Setup:**
```bash
cd django-image-scraper
pip install -r requirements.txt
python manage.py migrate
python manage.py runserver
```

Or with Docker:
```bash
cd django-image-scraper
docker-compose up
```

### 2. Angular Image Scraper

A modern frontend application built with Angular, focusing on responsive design and user experience.

**Technologies:**
- Angular 15+
- TypeScript
- TailwindCSS
- RxJS

**Key Features:**
- Responsive design for all devices
- Advanced state management
- Optimized image loading
- Dark/light mode support
- Accessibility compliance

**Setup:**
```bash
cd angular-image-scraper
npm install
npm start
```

### 3. Node Image Scraper

A REST API service built with Node.js, focusing on performance and scalability.

**Technologies:**
- Node.js & Express
- MongoDB
- JWT Authentication
- Docker support

**Key Features:**
- RESTful API design
- JWT-based authentication
- Image scraping from Google Images
- Alternative API-based image search (Pixabay)
- Image metadata extraction

**Setup:**
```bash
cd node-image-scraper
npm install
npm run dev
```

Or with Docker:
```bash
cd node-image-scraper
docker-compose up
```

### 4. Flutter Image Crawler

A cross-platform mobile application built with Flutter, providing a native experience on both iOS and Android.

**Technologies:**
- Flutter & Dart
- Provider/BLoC for state management
- HTTP client for API integration
- Local data persistence

**Key Features:**
- Cross-platform native experience
- Offline support
- Image caching
- Smooth transitions and animations
- Deep integration with mobile platform features

**Setup:**
```bash
cd image_crawler_flutter
flutter pub get
flutter run
```

## System Architecture

The applications follow different architectural patterns:

- **Django**: Monolithic MVC architecture with integrated ORM
- **Angular**: Component-based architecture with services
- **Node.js**: Microservice RESTful API with MVC pattern
- **Flutter**: BLoC/Provider pattern with repository layer

## API Integration

Each implementation can either:
1. Work independently (Django as full-stack)
2. Work in combination (Angular or Flutter frontend with Django or Node backend)

The backend services (Django and Node) provide similar API endpoints for:
- User authentication
- Image search and retrieval
- Social interactions (likes, comments)
- User profile management

## Requirements

### Backend (Django/Node)
- Python 3.8+ (Django) or Node.js 14+ (Node)
- Database: SQLite/PostgreSQL (Django) or MongoDB (Node)
- Docker & Docker Compose (optional)

### Frontend (Angular)
- Node.js 14+
- Angular CLI

### Mobile (Flutter)
- Flutter SDK 3.0+
- Dart 2.17+
- Android Studio / Xcode for emulators

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Contributors

- Alejandro González - Developer

### Característiques tècniques

- **Arquitectura**:
  - Aplicació monolítica desenvolupada amb Django 4.2
  - Base de dades SQLite
  - Frontend amb HTML, CSS (Tailwind) i JavaScript
  
- **Tecnologies emprades**:
  - **Backend**: Python, Django
  - **Frontend**: HTML5, Tailwind CSS, JavaScript
  - **Base de dades**: SQLite
  - **Extracció de dades**: BeautifulSoup, Requests
  - **Processament d'imatges**: Pillow

- **Implementacions avançades**:
  - Web scraping robust per extreure imatges de Google
  - Sistema de paginació
  - Gestió d'errors
  - Sistema de notificacions
  - Previsualització d'imatges amb modal
  - Imatges de tendència basades en "m'agrada"

## Instal·lació i configuració

### Requisits previs

- Python 3.8 o superior
- pip (gestor de paquets de Python)
- Navegador web modern

### Passos d'instal·lació

1. **Clonar el repositori**:
   ```bash
   git clone <url-del-repositori>
   cd django-image-scraper
   ```

2. **Crear i activar un entorn virtual**:
   ```bash
   python -m venv venv
   # En Windows:
   venv\Scripts\activate
   # En Unix/MacOS:
   source venv/bin/activate
   ```

3. **Instal·lar dependències**:
   ```bash
   pip install -r requirements.txt
   ```

4. **Aplicar les migracions de la base de dades**:
   ```bash
   python manage.py migrate
   ```

5. **Crear un superusuari (opcional)**:
   ```bash
   python manage.py createsuperuser
   ```

6. **Iniciar el servidor de desenvolupament**:
   ```bash
   python manage.py runserver
   ```

7. **Accedir a l'aplicació**:
   Obre el navegador i accedeix a `http://127.0.0.1:8000/`

## Ús de l'aplicació

### Cercar imatges

1. Introdueix el terme de cerca al camp de cerca a la pàgina principal
2. Opcionalment, selecciona filtres per drets d'autor o transparència
3. Fes clic a "Search Images" per obtenir resultats

### Interactuar amb imatges

1. Fes clic en una imatge per veure'n els detalls
2. Des de la vista detallada, pots:
   - Donar "m'agrada" a la imatge (requereix inici de sessió)
   - Afegir comentaris (requereix inici de sessió)
   - Veure imatges similars
   - Descarregar la imatge

### Gestió d'usuaris

1. Registra't mitjançant l'enllaç "Sign up"
2. Inicia sessió amb les teves credencials
3. Accedeix al teu perfil per veure el teu historial de cerques, imatges amb "m'agrada" i comentaris

## Personalització i desenvolupament

L'aplicació està dissenyada per ser extensible. Algunes àrees que es poden personalitzar:

- **Estils**: Modificant els arxius Tailwind CSS
- **Fonts de dades**: Canviant l'estratègia de scraping o utilitzant APIs d'imatges
- **Funcionalitats**: Afegint noves característiques a través de vistes de Django addicionals

## Configuració amb Docker

### Requisits previs per Docker

- Docker i Docker Compose instal·lats al sistema
- Git per clonar el repositori

### Passos per executar amb Docker

1. **Clonar el repositori**:
   ```bash
   git clone <url-del-repositori>
   cd django-image-scraper
   ```

2. **Construir i iniciar els contenidors**:
   ```bash
   docker-compose build
   docker-compose up -d
   ```

3. **Verificar que els contenidors estan en funcionament**:
   ```bash
   docker-compose ps
   ```

4. **Accedir a l'aplicació**:
   Obre el navegador i accedeix a `http://localhost/`

### Comandes útils de Docker

- **Veure registres de l'aplicació**:
  ```bash
  docker-compose logs -f web
  ```

- **Executar comandes dins del contenidor Django**:
  ```bash
  docker-compose exec web python manage.py [comanda]
  ```

- **Aturar tots els serveis**:
  ```bash
  docker-compose down
  ```

- **Aturar els serveis i eliminar volums de dades**:
  ```bash
  docker-compose down -v
  ```

### Estructura de contenidors

- **db**: PostgreSQL per emmagatzemar dades
- **web**: Aplicació Django servida amb Gunicorn
- **nginx**: Servidor web per servir contingut estàtic i actuar com a proxy invers

## Llicència

Aquest projecte és només per a finalitats educatives.
