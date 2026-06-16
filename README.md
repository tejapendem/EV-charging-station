# EV Connect India

> A cross-platform EV charging station discovery platform for India

EV Connect India helps electric vehicle owners find, navigate to, and review charging stations across India. Built with Flutter for mobile, Node.js/Express for the backend, PostgreSQL/PostGIS for spatial data, and React for the admin dashboard.

## Features

### Core
- **Interactive Map** — Browse charging stations on a Google Map with real-time availability
- **Smart Search** — Search by city, state, charger type, station name, or landmark
- **Nearby Stations** — GPS-based discovery with configurable radius (up to 100 km)
- **Station Details** — View connectors, pricing, amenities, photos, operating hours, and ratings
- **Route Planner** — Plan multi-stop EV trips with charging station waypoints
- **Filters** — Filter by charger type (CCS2, CHAdeMO, Type 2, Bharat DC/AC), speed category, amenities, and status

### Authentication
- **Email/Password** — Registration and login with JWT
- **Google Sign-In** — One-tap authentication via Firebase
- **Phone Auth** — OTP-based phone verification
- **Profile Management** — Update name, phone, vehicle info, and preferences

### User Engagement
- **Ratings & Reviews** — Rate stations 1–5 with detailed comments
- **Favorites** — Save and manage favorite stations
- **Issue Reporting** — Report closed stations, wrong locations, pricing issues, or broken chargers
- **Push Notifications** — Firebase Cloud Messaging for station updates and alerts
- **Dark Mode** — System-aware light/dark theme with smooth transitions

### Data
- **Offline Support** — Cached station data for offline browsing
- **Real-time Availability** — Connector status updates
- **Seed Data** — 12 pre-loaded stations across major Indian cities

### Admin
- **Admin Dashboard** — React-based admin panel for station management
- **Analytics** — Usage statistics, popular stations, and user growth charts
- **Report Management** — Review and resolve user-submitted issue reports
- **User Management** — View and manage users and roles

## Tech Stack

| Layer | Technology |
|---|---|
| Mobile App | Flutter 3.x, Dart 3.x |
| State Management | Riverpod 2.x |
| Navigation | GoRouter 14.x |
| Backend | Node.js, Express 4.x |
| Database | PostgreSQL 16 + PostGIS 3.x |
| Authentication | Firebase Auth, JWT (jsonwebtoken) |
| Maps | Google Maps Flutter, Geocoding API |
| Push Notifications | Firebase Cloud Messaging |
| Admin Dashboard | React 18, Material UI 5, Recharts |
| Containerization | Docker, docker-compose |
| Caching | flutter_secure_storage, shared_preferences |
| HTTP Client | http (Dart), axios (admin) |

## Screenshots

<!-- TODO: Add app screenshots -->
<p align="center">
  <img src="docs/screenshots/home.png" alt="Home Screen" width="200"/>
  <img src="docs/screenshots/map.png" alt="Map View" width="200"/>
  <img src="docs/screenshots/details.png" alt="Station Details" width="200"/>
  <img src="docs/screenshots/search.png" alt="Search" width="200"/>
</p>

## Architecture

```
┌─────────────────────────────────────────────────────┐
│                   Mobile App (Flutter)               │
│  ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌──────────┐ │
│  │ Auth UI │ │  Map UI │ │  Search │ │  Profile  │ │
│  └────┬────┘ └────┬────┘ └────┬────┘ └─────┬────┘ │
│       └───────────┴───────────┴─────────────┘      │
│                       │                             │
│              ┌────────┴────────┐                    │
│              │   Riverpod      │                    │
│              │   Providers     │                    │
│              └────────┬────────┘                    │
│              ┌────────┴────────┐                    │
│              │   ApiService    │                    │
│              └────────┬────────┘                    │
└───────────────────────┼─────────────────────────────┘
                        │ HTTP / JSON
┌───────────────────────┼─────────────────────────────┐
│            Backend (Node.js / Express)               │
│  ┌──────────┐ ┌───────────┐ ┌────────────────────┐  │
│  │  Auth    │ │  Stations │ │  Reviews / Reports  │  │
│  │  Routes  │ │  Routes   │ │  Routes            │  │
│  └────┬─────┘ └─────┬─────┘ └─────────┬──────────┘  │
│       └──────────────┴────────────────┘              │
│                      │                                │
│              ┌───────┴────────┐                      │
│              │   Controllers  │                      │
│              └───────┬────────┘                      │
│              ┌───────┴────────┐                      │
│              │   PostgreSQL   │                      │
│              │   + PostGIS    │                      │
│              └────────────────┘                      │
└──────────────────────────────────────────────────────┘
```

The Flutter app communicates with the Express backend over HTTP/JSON. Authentication uses Firebase Auth on the client side and JWT on the server. Station data is stored in PostgreSQL with PostGIS extensions for efficient location-based queries.

## Prerequisites

- **Flutter** 3.16+ with Dart 3.x
- **Node.js** 18.x or 20.x (LTS)
- **PostgreSQL** 14+ with **PostGIS** extension
- **Docker** & Docker Compose (optional, for containerized deployment)
- **Firebase** account with a project configured
- **Google Maps API** key with Maps SDK, Places API, and Geocoding API enabled

## Quick Start

### 1. Clone the repository

```bash
git clone https://github.com/your-org/ev-connect-india.git
cd ev-connect-india
```

### 2. Setup Backend

```bash
cd backend
cp .env.example .env
# Edit .env with your database credentials and API keys
npm install
npm run migrate
npm run seed
npm run dev
```

### 3. Setup Frontend (Flutter)

```bash
cd frontend
cp .env.example .env
# Edit .env with your Firebase and Google Maps config
flutter pub get
flutter run
```

### 4. Setup Admin Dashboard

```bash
cd admin-dashboard
cp .env.example .env
npm install
npm start
```

### 5. Using Docker (Alternative)

```bash
docker-compose up -d
```

This starts PostgreSQL, the backend API server, and the admin dashboard.

## Environment Variables

### Backend (`backend/.env`)

| Variable | Description | Default |
|---|---|---|
| `PORT` | API server port | `5000` |
| `NODE_ENV` | Environment (development/production) | `development` |
| `DB_HOST` | PostgreSQL host | `localhost` |
| `DB_PORT` | PostgreSQL port | `5432` |
| `DB_NAME` | Database name | `ev_connect_india` |
| `DB_USER` | Database user | `postgres` |
| `DB_PASSWORD` | Database password | — |
| `JWT_SECRET` | JWT signing secret | — |
| `JWT_EXPIRES_IN` | JWT token expiry | `7d` |
| `FIREBASE_PROJECT_ID` | Firebase project ID | — |
| `FIREBASE_PRIVATE_KEY` | Firebase service account private key | — |
| `FIREBASE_CLIENT_EMAIL` | Firebase service account client email | — |
| `GOOGLE_MAPS_API_KEY` | Google Maps / Geocoding API key | — |
| `MAX_FILE_SIZE` | Max upload file size (bytes) | `5242880` |
| `UPLOAD_DIR` | Upload directory | `uploads` |

### Frontend (`frontend/.env`)

| Variable | Description | Default |
|---|---|---|
| `API_BASE_URL` | Backend API URL | `https://api.evconnectindia.com/v1` |
| `GOOGLE_MAPS_API_KEY` | Google Maps SDK key | — |
| `GOOGLE_PLACES_API_KEY` | Google Places API key | — |
| `FIREBASE_API_KEY` | Firebase Web API key | — |
| `FIREBASE_APP_ID` | Firebase app ID | — |
| `FIREBASE_PROJECT_ID` | Firebase project ID | `ev-connect-india` |
| `FIREBASE_MESSAGING_SENDER_ID` | Firebase sender ID | — |
| `FIREBASE_STORAGE_BUCKET` | Firebase storage bucket | — |
| `FIREBASE_ANDROID_CLIENT_ID` | Android OAuth client ID | — |
| `FIREBASE_IOS_CLIENT_ID` | iOS OAuth client ID | — |

## Project Structure

```
├── backend/                          # Node.js + Express API server
│   ├── migrations/                   # SQL migration files
│   │   ├── 001_initial_schema.sql    # Database schema
│   │   └── 002_seed_data.sql         # Sample station data
│   ├── src/
│   │   ├── config/
│   │   │   ├── database.js           # PostgreSQL + PostGIS connection
│   │   │   └── firebase.js           # Firebase Admin SDK init
│   │   ├── controllers/
│   │   │   ├── authController.js     # Register, login, profile
│   │   │   ├── stationController.js  # CRUD + spatial queries
│   │   │   ├── reviewController.js   # Reviews CRUD
│   │   │   ├── favoriteController.js # Favorites CRUD
│   │   │   └── reportController.js   # Issue reports
│   │   ├── middleware/
│   │   │   ├── auth.js               # JWT + Firebase auth guards
│   │   │   ├── rateLimiter.js        # Rate limiting
│   │   │   ├── upload.js             # Multer file upload
│   │   │   └── validate.js           # express-validator handler
│   │   ├── routes/
│   │   │   ├── auth.js               # /api/auth/*
│   │   │   ├── stations.js           # /api/stations/*
│   │   │   ├── reviews.js            # /api/reviews/*
│   │   │   ├── favorites.js          # /api/favorites/*
│   │   │   └── reports.js            # /api/reports/*
│   │   ├── services/
│   │   │   ├── geocodingService.js   # Google Geocoding wrapper
│   │   │   └── notificationService.js# FCM push notifications
│   │   ├── utils/
│   │   │   └── helpers.js            # Shared utilities
│   │   └── app.js                    # Express app entry point
│   ├── uploads/                      # Uploaded station images
│   ├── Dockerfile
│   ├── package.json
│   └── .env.example
│
├── frontend/                         # Flutter mobile app
│   ├── lib/
│   │   ├── config/
│   │   │   ├── app_config.dart       # App-wide constants
│   │   │   └── routes.dart           # GoRouter route definitions
│   │   ├── features/
│   │   │   ├── add_station/          # Add station form
│   │   │   ├── auth/                 # Login, phone login screens
│   │   │   ├── favorites/            # Favorites list screen
│   │   │   ├── home/                 # Main shell + home screen
│   │   │   ├── map/                  # Map view + bottom sheet
│   │   │   ├── profile/              # User profile screen
│   │   │   ├── route_planner/        # Trip route planner
│   │   │   ├── search/               # Search + filter sheet
│   │   │   └── station_details/      # Details, review, report screens
│   │   ├── models/
│   │   │   ├── amenity.dart          # Amenity enum + model
│   │   │   ├── charger_type.dart     # ChargerType enum + ChargerConnector
│   │   │   ├── favorite.dart         # Favorite model
│   │   │   ├── report.dart           # Report model
│   │   │   ├── review.dart           # Review model
│   │   │   ├── station.dart          # Station, OperatingHours, PricingInfo
│   │   │   └── user_model.dart       # AppUser, VehicleInfo, enums
│   │   ├── providers/
│   │   │   ├── auth_provider.dart    # Auth state management
│   │   │   ├── favorites_provider.dart
│   │   │   ├── location_provider.dart
│   │   │   ├── station_provider.dart
│   │   │   └── theme_provider.dart   # Dark/light mode
│   │   ├── services/
│   │   │   ├── api_service.dart      # HTTP client with auth
│   │   │   ├── auth_service.dart     # Firebase + API auth
│   │   │   ├── cache_service.dart    # Local data caching
│   │   │   ├── location_service.dart # GPS location
│   │   │   └── station_service.dart  # Station API calls
│   │   ├── theme/
│   │   │   ├── app_theme.dart        # Material 3 theme definitions
│   │   │   └── color_schemes.dart    # EV-brand color palette
│   │   ├── utils/
│   │   │   ├── constants.dart        # UI constants
│   │   │   ├── formatters.dart       # Price, distance, time formatters
│   │   │   └── validators.dart       # Form input validators
│   │   ├── widgets/
│   │   │   ├── amenity_icon.dart
│   │   │   ├── charger_type_chip.dart
│   │   │   ├── empty_state.dart
│   │   │   ├── error_state.dart
│   │   │   ├── filter_sheet.dart
│   │   │   ├── rating_bar.dart
│   │   │   ├── search_bar_widget.dart
│   │   │   ├── skeleton_loader.dart
│   │   │   └── station_card.dart
│   │   └── main.dart                 # App entry point
│   ├── assets/
│   │   ├── fonts/
│   │   └── images/
│   ├── pubspec.yaml
│   └── .env.example
│
├── admin-dashboard/                  # React admin panel
│   ├── public/
│   ├── src/
│   │   ├── components/
│   │   ├── pages/
│   │   ├── services/
│   │   └── utils/
│   ├── package.json
│   └── Dockerfile
│
├── docker-compose.yml                # Production stack
├── README.md
├── API.md
├── SETUP.md
├── AGENTS.md
└── .gitignore
```

## API Documentation

See [API.md](API.md) for complete API documentation.

| Endpoint | Method | Description | Auth |
|---|---|---|---|
| `GET /api/health` | GET | Health check | No |
| `GET /api/version` | GET | API version info | No |
| `POST /api/auth/register` | POST | Register new user | No |
| `POST /api/auth/login` | POST | Login with email/password | No |
| `POST /api/auth/google` | POST | Google sign-in | No |
| `GET /api/auth/profile` | GET | Get user profile | Yes |
| `PUT /api/auth/profile` | PUT | Update profile | Yes |
| `PUT /api/auth/fcm-token` | PUT | Update FCM token | Yes |
| `GET /api/stations` | GET | List all stations | No |
| `GET /api/stations/nearby` | GET | Find nearby stations | No |
| `GET /api/stations/search` | GET | Search stations | No |
| `GET /api/stations/:id` | GET | Get station details | No |
| `GET /api/stations/:id/chargers` | GET | Get station chargers | No |
| `POST /api/stations` | POST | Create station | Yes |
| `PUT /api/stations/:id` | PUT | Update station | Admin |
| `DELETE /api/stations/:id` | DELETE | Delete station | Admin |
| `POST /api/reviews` | POST | Create review | Yes |
| `GET /api/reviews/:stationId` | GET | Get station reviews | No |
| `GET /api/reviews/my-reviews` | GET | Get user's reviews | Yes |
| `DELETE /api/reviews/:id` | DELETE | Delete review | Yes |
| `POST /api/favorites` | POST | Add favorite | Yes |
| `GET /api/favorites` | GET | List favorites | Yes |
| `GET /api/favorites/check/:stationId` | GET | Check if favorited | Yes |
| `DELETE /api/favorites/:id` | DELETE | Remove favorite | Yes |
| `POST /api/reports` | POST | Create report | Yes |
| `GET /api/reports/my-reports` | GET | Get user's reports | Yes |
| `GET /api/reports` | GET | List all reports | Admin |
| `PUT /api/reports/:id` | PUT | Update report status | Admin |

## Database Schema

### Tables

| Table | Description |
|---|---|
| `users` | User accounts with roles and auth provider info |
| `charging_stations` | Station details with PostGIS geography column |
| `charger_types` | Connectors available at each station |
| `station_amenities` | Amenities (restrooms, food, WiFi, parking, hotel) |
| `station_images` | Station photos with primary flag |
| `reviews` | User ratings and comments (one review per user per station) |
| `favorites` | User saved stations |
| `reports` | Issue reports with status tracking |
| `notifications` | Push notification history |

### Key Features

- **PostGIS** `GEOGRAPHY(Point, 4326)` for efficient `ST_DWithin` distance queries
- **Full-text search** GIN index on station name, address, city, state
- **Automatic `updated_at`** triggers on all mutable tables
- **Rating cascade** trigger updates station `updated_at` on review changes
- **UUID primary keys** throughout
- **Check constraints** on ratings (1–5), quantities (>0)

## Firebase Setup

1. Go to [Firebase Console](https://console.firebase.google.com) and create a project
2. Enable **Authentication** — add Email/Password, Google, and Phone sign-in providers
3. Register your Android app (package: `com.evconnectindia.app`) and iOS app
4. Download `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) into `frontend/android/app/` and `frontend/ios/Runner/`
5. Go to **Project Settings > Service accounts** and generate a new private key
6. Save the JSON — use its values for `FIREBASE_PROJECT_ID`, `FIREBASE_PRIVATE_KEY`, and `FIREBASE_CLIENT_EMAIL` in `backend/.env`
7. Enable **Cloud Messaging** (FCM) for push notifications

## Google Maps Setup

1. Go to [Google Cloud Console](https://console.cloud.google.com)
2. Create or select your project
3. Enable APIs:
   - Maps SDK for Android
   - Maps SDK for iOS
   - Places API (for autocomplete)
   - Geocoding API (for address resolution)
4. Create a credential — **API Key**
5. Restrict the key to the APIs above and your app's package name/bundle ID
6. Set the key as `GOOGLE_MAPS_API_KEY` in both `frontend/.env` and `backend/.env`

## Deployment

### Docker (Production)

```bash
docker-compose up -d --build
```

This builds and starts:
- **PostgreSQL** on port 5432
- **Backend API** on port 5000
- **Admin dashboard** on port 80

### VPS / Cloud VM

1. Provision a VM (Ubuntu 22.04) with Docker and Docker Compose installed
2. Copy `docker-compose.yml` and `.env` to the server
3. Set `NODE_ENV=production` and update CORS origins in `.env`
4. Run `docker-compose up -d`
5. Set up Nginx reverse proxy with SSL (Let's Encrypt)

### Manual Deployment

**Backend:**
```bash
cd backend
NODE_ENV=production npm start
```

## Mobile App Build

### Android APK

```bash
cd frontend
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

### Android App Bundle

```bash
flutter build appbundle --release
# Output: build/app/outputs/bundle/release/app-release.aab
```

### iOS IPA

```bash
cd frontend/ios
pod install
cd ..
flutter build ios --release
# Then archive via Xcode: Product > Archive
```

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

Please ensure your code follows the existing conventions (see [AGENTS.md](AGENTS.md)).

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
# EV-charging-station
