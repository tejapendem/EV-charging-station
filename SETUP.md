# EV Connect India — Setup Guide

## Prerequisites

Install the following tools on your development machine:

| Tool | Version | Download |
|---|---|---|
| Flutter | 3.16+ | https://docs.flutter.dev/get-started/install |
| Dart | 3.x | Bundled with Flutter |
| Node.js | 18.x or 20.x LTS | https://nodejs.org/ |
| npm | 9+ | Bundled with Node.js |
| PostgreSQL | 14+ | https://www.postgresql.org/download/ |
| PostGIS | 3.x | `CREATE EXTENSION postgis;` |
| Docker | Latest | https://docs.docker.com/get-docker/ |
| Git | Latest | https://git-scm.com/ |

Verify installations:

```bash
flutter --version
node --version
npm --version
psql --version
docker --version
```

### Platform-Specific Notes

**macOS:**
```bash
brew install postgresql postgis
brew services start postgresql
```

**Ubuntu/Debian:**
```bash
sudo apt update
sudo apt install postgresql postgresql-contrib postgis
sudo systemctl start postgresql
```

**Windows:**
Download the EDB PostgreSQL installer which includes PostGIS: https://www.enterprisedb.com/downloads/postgres-postgresql-downloads

---

## Step 1: Clone the Repository

```bash
git clone https://github.com/your-org/ev-connect-india.git
cd ev-connect-india
```

---

## Step 2: Firebase Project Setup

### Create a Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click **Create a project** (or select existing)
3. Enter project name: `EV Connect India`
4. Disable Google Analytics (optional), click **Create Project**

### Enable Authentication Providers

1. In Firebase Console, go to **Authentication > Sign-in method**
2. Enable the following providers:

| Provider | Configuration |
|---|---|
| **Email/Password** | Enable (no further config needed) |
| **Google** | Enable, select a project support email |
| **Phone** | Enable (requires physical device for testing) |

### Register Android App

1. In **Project Settings > General > Your apps**, click **Add app > Android**
2. Package name: `com.evconnectindia.app`
3. App nickname: `EV Connect India Android`
4. Download `google-services.json`
5. Place it at: `frontend/android/app/google-services.json`

### Register iOS App

1. **Add app > iOS**
2. Bundle ID: `com.evconnectindia.app`
3. Download `GoogleService-Info.plist`
4. Place it at: `frontend/ios/Runner/GoogleService-Info.plist`

### Generate Service Account Key

1. **Project Settings > Service accounts**
2. Click **Generate new private key**
3. Download the JSON file
4. Extract the following values for `backend/.env`:
   - `FIREBASE_PROJECT_ID` — from `project_id`
   - `FIREBASE_PRIVATE_KEY` — from `private_key` (keep the `\n` line breaks)
   - `FIREBASE_CLIENT_EMAIL` — from `client_email`

### Enable Cloud Messaging

1. **Cloud Messaging** tab in Project Settings
2. Note the **Server key** and **Sender ID** for future use
3. The `FIREBASE_MESSAGING_SENDER_ID` is shown on this page

### Generate SHA-1 Fingerprint (Android)

```bash
# For debug
cd frontend/android
./gradlew signingReport
```

Copy the SHA-1 from the debug variant. Add it in **Project Settings > General > Your apps > Android app > SHA certificate fingerprints**.

This is required for Google Sign-In and Phone Auth.

---

## Step 3: Google Maps API Key

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select your Firebase project
3. Navigate to **APIs & Services > Library**
4. Enable the following APIs:

| API | Purpose |
|---|---|
| Maps SDK for Android | Display maps in the app |
| Maps SDK for iOS | Display maps in the app |
| Places API | Location autocomplete |
| Geocoding API | Address ↔ Lat/Lng conversion |

5. Go to **Credentials > Create Credentials > API Key**
6. Restrict the key:
   - **Application restrictions:** Android apps + iOS apps
   - Add your app's package name (`com.evconnectindia.app`) and SHA-1 fingerprint for Android
   - Add your iOS bundle ID (`com.evconnectindia.app`)
   - **API restrictions:** Restrict to the 4 APIs above

7. Save the key — it will be used in both `frontend/.env` and `backend/.env`

---

## Step 4: Backend Configuration

```bash
cd backend
cp .env.example .env
```

Edit `backend/.env`:

```env
# Server
PORT=5000
NODE_ENV=development

# Database
DB_HOST=localhost
DB_PORT=5432
DB_NAME=ev_connect_india
DB_USER=postgres
DB_PASSWORD=your_secure_password

# JWT
JWT_SECRET=your_random_64_char_secret_here_change_in_production
JWT_EXPIRES_IN=7d

# Firebase
FIREBASE_PROJECT_ID=your-firebase-project-id
FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\nYOUR_KEY_HERE\n-----END PRIVATE KEY-----"
FIREBASE_CLIENT_EMAIL=firebase-adminsdk-xxxxx@your-project-id.iam.gserviceaccount.com

# Google
GOOGLE_MAPS_API_KEY=your_google_maps_api_key
```

Generate a strong JWT secret:

```bash
node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"
```

Install dependencies:

```bash
npm install
```

---

## Step 5: Database Setup

### Create the Database

```bash
# Connect to PostgreSQL
psql -U postgres

# Create the database
CREATE DATABASE ev_connect_india;

# Enable PostGIS
\c ev_connect_india
CREATE EXTENSION IF NOT EXISTS postgis;
CREATE EXTENSION IF NOT EXISTS postgis_topology;

# Verify
\dx

# Exit
\q
```

### Run Migrations

```bash
cd backend
npm run migrate
```

This runs `migrations/001_initial_schema.sql` which creates all tables, enums, indexes, and triggers.

### Seed Sample Data (Optional)

```bash
npm run seed
```

This inserts 12 sample EV charging stations across major Indian cities (Mumbai, Delhi, Bangalore, Hyderabad, Chennai, Pune, Ahmedabad, Kolkata, Jaipur, Lucknow, Surat, Chandigarh).

### Verify

```bash
psql -U postgres -d ev_connect_india -c "SELECT COUNT(*) FROM charging_stations;"
# Should return: 12 (or 0 if not seeded)
```

---

## Step 6: Flutter App Configuration

```bash
cd frontend
cp .env.example .env
```

Edit `frontend/.env`:

```env
API_BASE_URL=http://localhost:5000/api
GOOGLE_MAPS_API_KEY=your_google_maps_api_key
GOOGLE_PLACES_API_KEY=your_google_places_api_key
FIREBASE_API_KEY=your_firebase_api_key
FIREBASE_APP_ID=your_firebase_app_id
FIREBASE_PROJECT_ID=ev-connect-india
FIREBASE_MESSAGING_SENDER_ID=your_sender_id
FIREBASE_STORAGE_BUCKET=your-project.appspot.com
FIREBASE_ANDROID_CLIENT_ID=your_android_client_id
FIREBASE_IOS_CLIENT_ID=your_ios_client_id
```

Install Flutter dependencies:

```bash
flutter pub get
```

Set environment variables at build time using `--dart-define`:

```bash
flutter run --dart-define=GOOGLE_MAPS_API_KEY=your_key --dart-define=FIREBASE_API_KEY=your_key
```

For Android, ensure your `android/app/build.gradle` has the compile SDK version compatible with the project:

```gradle
android {
    compileSdkVersion 34
    // ...
}
```

Run code generation (if using freezed / json_serializable):

```bash
dart run build_runner build --delete-conflicting-outputs
```

---

## Step 7: Running the App

### Start the Backend

```bash
cd backend
npm run dev
```

The API server starts on `http://localhost:5000`. Verify:

```bash
curl http://localhost:5000/api/health
# {"success":true,"message":"EV Connect India API is running",...}
```

### Start the Flutter App

```bash
cd frontend
flutter run
```

To run on a specific device:

```bash
flutter run -d chrome          # Web
flutter run -d android_device  # Android emulator/device
flutter run -d ios             # iOS simulator
```

### Start the Admin Dashboard

```bash
cd admin-dashboard
npm install
npm start
```

The dashboard runs on `http://localhost:3000`.

---

## Step 8: Docker Deployment (Optional)

### Development with Docker

```bash
docker-compose up -d
```

This starts:
- PostgreSQL on port `5432`
- Backend API on port `5000`
- Admin dashboard on port `3000`

To rebuild:

```bash
docker-compose up -d --build
```

### Run Migrations in Docker

```bash
docker-compose exec backend npm run migrate
docker-compose exec backend npm run seed
```

### Production Deployment

For production, create a `docker-compose.prod.yml` with:
- Production-grade PostgreSQL with persistent volumes
- Nginx reverse proxy with SSL
- Environment variables via `.env` file

Example production `docker-compose.yml`:

```yaml
version: '3.8'

services:
  db:
    image: postgis/postgis:16-3.4
    restart: always
    environment:
      POSTGRES_DB: ev_connect_india
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: ${DB_PASSWORD}
    volumes:
      - pgdata:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 10s
      timeout: 5s
      retries: 5

  backend:
    build: ./backend
    restart: always
    ports:
      - "5000:5000"
    env_file: .env
    depends_on:
      db:
        condition: service_healthy

  admin:
    build: ./admin-dashboard
    restart: always
    ports:
      - "3000:3000"
    depends_on:
      - backend

volumes:
  pgdata:
```

---

## Troubleshooting

### Database Connection Issues

**Error:** `ECONNREFUSED 127.0.0.1:5432`

```bash
# Check if PostgreSQL is running
pg_isready
# If not running:
brew services start postgresql  # macOS
sudo systemctl start postgresql  # Linux

# Verify credentials
psql -U postgres -d ev_connect_india -c "SELECT 1;"
```

### PostGIS Extension Missing

**Error:** `extension "postgis" not available`

```bash
# Install PostGIS (macOS)
brew install postgis

# Install PostGIS (Ubuntu)
sudo apt install postgis postgresql-16-postgis-3

# Manually enable in the database
psql -U postgres -d ev_connect_india -c "CREATE EXTENSION postgis;"
```

### Flutter Build Errors

**Error:** `gradle build failed`

```bash
cd frontend/android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter run
```

**Error:** `google-services.json not found`

Ensure `google-services.json` is placed at `frontend/android/app/google-services.json`.

**Error:** `Google Maps shows blank tiles`

- Verify your API key is correct
- Ensure Maps SDK is enabled in Google Cloud Console
- Check that the API key has no referrer/IP restrictions that block localhost
- For Android: verify SHA-1 fingerprint is registered

### Firebase Auth Issues

**Error:** `FirebaseException` during authentication

- Ensure the Firebase project has the auth provider enabled
- For phone auth: use a real device (not emulator)
- For Google sign-in: verify SHA-1 and web client ID configuration
- Confirm `google-services.json` is current (regenerate if needed)

### Backend CORS Errors

If the Flutter app cannot reach the backend:

- Verify the backend is running (`curl http://localhost:5000/api/health`)
- Check CORS config in `backend/src/app.js` — add your frontend URL to the origin list
- For Android emulator, use `10.0.2.2` instead of `localhost` in `API_BASE_URL`

### Flutter Web

The Google Maps Flutter plugin has limited web support. For web testing:

```bash
flutter run -d chrome --dart-define=FLUTTER_WEB_USE_SKIA=true
```

### Port Conflicts

If port 5000 or 5432 is in use:

```bash
# Check what's using the port
lsof -i :5000
lsof -i :5432

# Kill the process
kill -9 <PID>
```

### Reset the Database

```bash
psql -U postgres -c "DROP DATABASE IF EXISTS ev_connect_india;"
psql -U postgres -c "CREATE DATABASE ev_connect_india;"
psql -U postgres -d ev_connect_india -c "CREATE EXTENSION postgis;"
cd backend && npm run migrate && npm run seed
```
