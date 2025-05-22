# Suite de Projectes Image Crawler

## Visió general

Aquest repositori conté quatre implementacions diferents d'una aplicació Image Crawler, cadascuna desenvolupada amb tecnologies diferents per demostrar diversos enfocaments per resoldre el mateix problema. La suite de projectes inclou:

1. **Django Image Scraper**: Una aplicació web completa construïda amb Django
2. **Angular Image Scraper**: Una aplicació frontend moderna construïda amb Angular
3. **Node Image Scraper**: Un servei API REST construït amb Node.js
4. **Flutter Image Crawler**: Una aplicació mòbil multiplataforma

Totes les implementacions proporcionen funcionalitats bàsiques similars però mostren arquitectures i piles tecnològiques diferents.

## Funcionalitats principals en totes les plataformes

- 🔍 **Cerca avançada d'imatges** amb múltiples filtres
- 🖼️ **Descobriment d'imatges** de diverses fonts
- 👤 **Autenticació d'usuaris** i gestió de perfils
- 💾 **Guardar i organitzar** imatges preferides
- 💬 **Interaccions socials** - comentaris i m'agrada
- 📊 **Seguiment de l'historial** de cerques

## Estructura del projecte

```
image-crawler/
├── angular-image-scraper/   # Frontend Angular
├── django-image-scraper/    # Aplicació web completa amb Django
├── node-image-scraper/      # Backend API amb Node.js
└── image_crawler_flutter/   # Aplicació mòbil Flutter
```

## Aplicacions

### 1. Django Image Scraper

Una aplicació web completa construïda amb Django, que proporciona funcionalitats de backend i frontend.

**Tecnologies:**
- Django i Django REST Framework
- SQLite/PostgreSQL
- Tailwind CSS

**Funcionalitats clau:**
- Raspat d'imatges de Google Images amb filtres
- Autenticació i perfils d'usuari
- M'agrada i comentaris d'imatges
- Extracció de metadades d'imatges
- Interfície web responsive

**Configuració:**
```bash
cd django-image-scraper
pip install -r requirements.txt
python manage.py migrate
python manage.py runserver
```

### 2. Angular Image Scraper

Una aplicació frontend moderna construïda amb Angular, centrada en el disseny responsive i l'experiència d'usuari.

**Tecnologies:**
- Angular 15+
- TypeScript
- TailwindCSS
- RxJS

**Funcionalitats clau:**
- Disseny responsive per a tots els dispositius
- Gestió avançada de l'estat
- Càrrega optimitzada d'imatges
- Suport per a mode fosc/clar
- Compliment d'accessibilitat

**Configuració:**
```bash
cd angular-image-scraper
npm install
npm start
```

### 3. Node Image Scraper

Un servei API REST construït amb Node.js, centrat en el rendiment i l'escalabilitat.

**Tecnologies:**
- Node.js i Express
- MongoDB
- Autenticació JWT

**Funcionalitats clau:**
- Disseny API RESTful
- Autenticació basada en JWT
- Raspat d'imatges de Google Images
- Cerca alternativa d'imatges basada en API (Pixabay)
- Extracció de metadades d'imatges

**Configuració:**
```bash
# Primer, iniciar MongoDB (necessari per al servidor Node.js)
docker run -d --name mongodb -p 27017:27017 mongo:latest

# Després configurar i iniciar el servidor
cd node-image-scraper
npm install
npm run dev
```

### 4. Flutter Image Crawler

Una aplicació mòbil multiplataforma construïda amb Flutter, que proporciona una experiència nativa tant a iOS com a Android.

**Tecnologies:**
- Flutter i Dart
- Provider/BLoC per a la gestió d'estat
- Client HTTP per a integració amb API
- Persistència de dades local

**Funcionalitats clau:**
- Experiència nativa multiplataforma
- Suport offline
- Emmagatzematge en caché d'imatges
- Transicions i animacions suaus
- Integració profunda amb característiques de la plataforma mòbil

**Configuració:**
```bash
cd image_crawler_flutter
flutter pub get
flutter run
```

## Arquitectura del sistema

Les aplicacions segueixen diferents patrons arquitectònics:

- **Django**: Arquitectura MVC monolítica amb ORM integrat
- **Angular**: Arquitectura basada en components amb serveis
- **Node.js**: API RESTful de microserveis amb patró MVC
- **Flutter**: Patró BLoC/Provider amb capa de repositori

## Integració API

Cada implementació pot:
1. Funcionar de manera independent (Django com a full-stack)
2. Funcionar en combinació (Angular o Flutter frontend amb Django o Node backend)

Els serveis de backend (Django i Node) proporcionen punts finals d'API similars per a:
- Autenticació d'usuaris
- Cerca i recuperació d'imatges
- Interaccions socials (m'agrada, comentaris)
- Gestió de perfils d'usuari

## Requisits

### Backend (Django/Node)
- Python 3.8+ (Django) o Node.js 14+ (Node)
- Base de dades: SQLite/PostgreSQL (Django) o MongoDB (Node)

### Frontend (Angular)
- Node.js 14+
- Angular CLI

### Mòbil (Flutter)
- Flutter SDK 3.0+
- Dart 2.17+
- Android Studio / Xcode per als emuladors

## Llicència

Aquest projecte està llicenciat sota la Llicència MIT - consulteu l'arxiu LICENSE per a més detalls.

