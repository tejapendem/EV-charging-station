# EV Connect India API Documentation

**Base URL:** `https://api.evconnectindia.com/v1` (production) or `http://localhost:5000/api` (development)

**Content-Type:** `application/json`

## Authentication

Most endpoints require a JWT Bearer token in the `Authorization` header:

```
Authorization: Bearer <jwt_token>
```

Tokens are obtained via `POST /auth/login` or `POST /auth/register`. They expire after the duration set in `JWT_EXPIRES_IN` (default: 7 days).

### Error Response Format

All error responses follow this structure:

```json
{
  "success": false,
  "message": "Error description"
}
```

Validation errors include an `errors` field:

```json
{
  "success": false,
  "message": "Validation failed",
  "errors": {
    "email": "Please provide a valid email address",
    "password": "Password must be between 8 and 128 characters"
  }
}
```

---

## Rate Limiting

| Limiter | Window | Max Requests |
|---|---|---|
| Global | 15 minutes | 100 |
| Auth (login/register) | 15 minutes | 10 |
| API (general) | 1 minute | 60 |
| Station creation | 1 hour | 5 |

Rate limit headers: `RateLimit-Limit`, `RateLimit-Remaining`, `RateLimit-Reset`

---

## Health & Version

### Health Check

```
GET /api/health
```

Response `200`:
```json
{
  "success": true,
  "message": "EV Connect India API is running",
  "timestamp": "2024-01-01T00:00:00.000Z",
  "environment": "development"
}
```

### Version

```
GET /api/version
```

Response `200`:
```json
{
  "success": true,
  "data": {
    "version": "1.0.0",
    "name": "EV Connect India API",
    "description": "EV Charging Station Finder Backend"
  }
}
```

---

## Authentication Endpoints

### Register

```
POST /api/auth/register
```

**Rate limit:** 10 per 15 minutes

**Request body:**
```json
{
  "name": "Ravi Sharma",
  "email": "ravi@example.com",
  "password": "SecurePass123",
  "phone": "+919876543210"
}
```

**Validation rules:**
- `name`: 2–100 characters
- `email`: valid email format
- `password`: 8–128 characters, at least 1 uppercase, 1 lowercase, 1 digit
- `phone` (optional): 10–15 digits with optional `+`

**Response `201`:**
```json
{
  "success": true,
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIs...",
    "user": {
      "id": "550e8400-e29b-41d4-a716-446655440000",
      "name": "Ravi Sharma",
      "email": "ravi@example.com",
      "phone": "+919876543210",
      "role": "user",
      "is_verified": false,
      "created_at": "2024-01-01T00:00:00.000Z"
    }
  }
}
```

### Login

```
POST /api/auth/login
```

**Rate limit:** 10 per 15 minutes

**Request body:**
```json
{
  "email": "ravi@example.com",
  "password": "SecurePass123"
}
```

**Response `200`:**
```json
{
  "success": true,
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIs...",
    "user": {
      "id": "550e8400-e29b-41d4-a716-446655440000",
      "name": "Ravi Sharma",
      "email": "ravi@example.com",
      "role": "user"
    }
  }
}
```

**Error `401`:**
```json
{
  "success": false,
  "message": "Invalid email or password"
}
```

### Google Sign-In

```
POST /api/auth/google
```

**Rate limit:** 10 per 15 minutes

**Request body:**
```json
{
  "idToken": "firebase_id_token_from_google_sign_in"
}
```

**Response `200`:** Same as login, with auto-created user if new.

### Get Profile

```
GET /api/auth/profile
```

**Auth:** Bearer token required

**Response `200`:**
```json
{
  "success": true,
  "data": {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "name": "Ravi Sharma",
    "email": "ravi@example.com",
    "phone": "+919876543210",
    "avatar_url": "https://example.com/avatar.jpg",
    "role": "user",
    "is_verified": true,
    "created_at": "2024-01-01T00:00:00.000Z"
  }
}
```

### Update Profile

```
PUT /api/auth/profile
```

**Auth:** Bearer token required

**Request body:**
```json
{
  "name": "Ravi Kumar Sharma",
  "phone": "+919876543211"
}
```

**Response `200`:** Updated profile object.

### Update FCM Token

```
PUT /api/auth/fcm-token
```

**Auth:** Bearer token required

**Request body:**
```json
{
  "fcmToken": "firebase_cloud_messaging_token"
}
```

**Response `200`:**
```json
{
  "success": true,
  "message": "FCM token updated successfully"
}
```

---

## Station Endpoints

### Get All Stations

```
GET /api/stations
```

**Auth:** None

**Query parameters:**

| Param | Type | Default | Description |
|---|---|---|---|
| `page` | int | 1 | Page number |
| `limit` | int | 20 | Items per page (max 100) |
| `status` | string | — | Filter: ACTIVE, INACTIVE, UNDER_MAINTENANCE |

**Response `200`:**
```json
{
  "success": true,
  "data": [
    {
      "id": "550e8400-e29b-41d4-a716-446655440001",
      "name": "Tata Power EZ Station - BKC",
      "address": "Ground Floor, Platina Building, Bandra Kurla Complex",
      "city": "Mumbai",
      "state": "Maharashtra",
      "pincode": "400051",
      "latitude": 19.0602,
      "longitude": 72.8697,
      "status": "ACTIVE",
      "price_per_kwh": 12.50,
      "rating": 4.2,
      "total_reviews": 15,
      "is_verified": true
    }
  ],
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 12,
    "total_pages": 1
  }
}
```

### Find Nearby Stations

```
GET /api/stations/nearby
```

**Auth:** None

**Query parameters:**

| Param | Type | Default | Description |
|---|---|---|---|
| `lat` | float | **required** | Latitude (-90 to 90) |
| `lng` | float | **required** | Longitude (-180 to 180) |
| `radius` | float | 10 | Search radius in km (0.1–500) |
| `page` | int | 1 | Page number |
| `limit` | int | 20 | Items per page (max 100) |

**Response `200`:**
```json
{
  "success": true,
  "data": [
    {
      "id": "550e8400-e29b-41d4-a716-446655440001",
      "name": "Tata Power EZ Station - BKC",
      "address": "Ground Floor, Platina Building, Bandra Kurla Complex",
      "city": "Mumbai",
      "latitude": 19.0602,
      "longitude": 72.8697,
      "distance_km": 1.2,
      "status": "ACTIVE",
      "price_per_kwh": 12.50,
      "rating": 4.2,
      "total_reviews": 15,
      "connectors": [
        {
          "charger_type": "CCS2",
          "power_output": 150.00,
          "speed_category": "ULTRA_FAST",
          "quantity": 4,
          "available": 2,
          "price_per_kwh": 12.50
        }
      ],
      "amenities": ["RESTROOMS", "WIFI", "PARKING"]
    }
  ]
}
```

### Search Stations

```
GET /api/stations/search
```

**Auth:** None

**Query parameters:**

| Param | Type | Description |
|---|---|---|
| `q` | string | Search query (min 2 chars) — matches name, address, city, state, pincode |
| `city` | string | Filter by city |
| `state` | string | Filter by state |
| `charger_type` | string | Filter by charger type: CCS2, Type2, CHAdeMO, Bharat_DC001, Bharat_AC001 |
| `status` | string | Filter by status: ACTIVE, INACTIVE, UNDER_MAINTENANCE |

**Response `200`:** Same structure as `GET /api/stations`.

### Get Station Details

```
GET /api/stations/:id
```

**Auth:** None

**Response `200`:**
```json
{
  "success": true,
  "data": {
    "id": "550e8400-e29b-41d4-a716-446655440001",
    "name": "Tata Power EZ Station - BKC",
    "address": "Ground Floor, Platina Building, Bandra Kurla Complex",
    "city": "Mumbai",
    "state": "Maharashtra",
    "pincode": "400051",
    "highway": "Western Express Highway",
    "landmark": "Near BKC Signal",
    "latitude": 19.0602,
    "longitude": 72.8697,
    "phone": "+91-22-6789-1000",
    "operating_hours": "24/7",
    "price_per_kwh": 12.50,
    "status": "ACTIVE",
    "is_verified": true,
    "rating": 4.2,
    "total_reviews": 15,
    "chargers": [
      {
        "id": "660e8400-e29b-41d4-a716-446655440001",
        "charger_type": "CCS2",
        "power_output": 150.00,
        "speed_category": "ULTRA_FAST",
        "quantity": 4,
        "connector_status": "ACTIVE",
        "price_per_kwh": 12.50
      }
    ],
    "amenities": [
      {"amenity": "RESTROOMS"},
      {"amenity": "WIFI"},
      {"amenity": "PARKING"}
    ],
    "images": [
      {"image_url": "https://example.com/image1.jpg", "is_primary": true}
    ],
    "created_at": "2024-01-01T00:00:00.000Z",
    "updated_at": "2024-01-01T00:00:00.000Z"
  }
}
```

**Error `404`:**
```json
{
  "success": false,
  "message": "Station not found"
}
```

### Get Station Chargers

```
GET /api/stations/:id/chargers
```

**Auth:** None

**Response `200`:**
```json
{
  "success": true,
  "data": [
    {
      "id": "660e8400-e29b-41d4-a716-446655440001",
      "charger_type": "CCS2",
      "power_output": 150.00,
      "speed_category": "ULTRA_FAST",
      "quantity": 4,
      "connector_status": "ACTIVE",
      "price_per_kwh": 12.50
    }
  ]
}
```

### Create Station

```
POST /api/stations
```

**Auth:** Bearer token required

**Rate limit:** 5 per hour

**Content-Type:** `multipart/form-data`

**Form fields:**

| Field | Type | Required | Description |
|---|---|---|---|
| `name` | string | Yes | Station name (2–200 chars) |
| `address` | string | Yes | Full address (5–500 chars) |
| `city` | string | Yes | City name (2–100 chars) |
| `state` | string | Yes | State name (2–100 chars) |
| `pincode` | string | No | 6-digit pincode |
| `latitude` | float | No | Latitude (-90 to 90) |
| `longitude` | float | No | Longitude (-180 to 180) |
| `phone` | string | No | Contact number |
| `status` | string | No | ACTIVE, INACTIVE, UNDER_MAINTENANCE |
| `chargers` | JSON arr | No | Array of charger objects |
| `amenities` | JSON arr | No | Array of amenity strings |
| `image` | file | No | Station image upload |

**Response `201`:**
```json
{
  "success": true,
  "data": {
    "id": "550e8400-e29b-41d4-a716-446655440010",
    "name": "New Station",
    "status": "ACTIVE",
    "created_at": "2024-01-01T00:00:00.000Z"
  }
}
```

### Update Station

```
PUT /api/stations/:id
```

**Auth:** Bearer token required — Admin only

**Response `200`:** Updated station object.

### Delete Station

```
DELETE /api/stations/:id
```

**Auth:** Bearer token required — Admin only

**Response `200`:**
```json
{
  "success": true,
  "message": "Station deleted successfully"
}
```

---

## Review Endpoints

### Create Review

```
POST /api/reviews
```

**Auth:** Bearer token required

**Request body:**
```json
{
  "station_id": "550e8400-e29b-41d4-a716-446655440001",
  "rating": 4,
  "comment": "Great charging station with ample parking and clean restrooms."
}
```

**Validation rules:**
- `station_id`: valid UUID
- `rating`: integer 1–5
- `comment` (optional): 10–1000 characters

**Response `201`:**
```json
{
  "success": true,
  "data": {
    "id": "770e8400-e29b-41d4-a716-446655440001",
    "rating": 4,
    "comment": "Great charging station with ample parking and clean restrooms.",
    "created_at": "2024-01-01T00:00:00.000Z"
  }
}
```

**Error `409`:**
```json
{
  "success": false,
  "message": "You have already reviewed this station"
}
```

### Get Station Reviews

```
GET /api/reviews/:stationId
```

**Auth:** None

**Response `200`:**
```json
{
  "success": true,
  "data": [
    {
      "id": "770e8400-e29b-41d4-a716-446655440001",
      "user_id": "550e8400-e29b-41d4-a716-446655440000",
      "user_name": "Ravi Sharma",
      "user_avatar": "https://example.com/avatar.jpg",
      "rating": 4,
      "comment": "Great charging station with ample parking.",
      "created_at": "2024-01-01T00:00:00.000Z"
    }
  ]
}
```

### Get My Reviews

```
GET /api/reviews/my-reviews
```

**Auth:** Bearer token required

Returns all reviews by the authenticated user.

### Delete Review

```
DELETE /api/reviews/:id
```

**Auth:** Bearer token required (owner or admin)

**Response `200`:**
```json
{
  "success": true,
  "message": "Review deleted successfully"
}
```

---

## Favorites Endpoints

All favorites endpoints require authentication.

### Add Favorite

```
POST /api/favorites
```

**Request body:**
```json
{
  "station_id": "550e8400-e29b-41d4-a716-446655440001"
}
```

**Response `201`:**
```json
{
  "success": true,
  "data": {
    "id": "880e8400-e29b-41d4-a716-446655440001",
    "station_id": "550e8400-e29b-41d4-a716-446655440001",
    "created_at": "2024-01-01T00:00:00.000Z"
  }
}
```

### List Favorites

```
GET /api/favorites
```

**Response `200`:**
```json
{
  "success": true,
  "data": [
    {
      "id": "880e8400-e29b-41d4-a716-446655440001",
      "station": {
        "id": "550e8400-e29b-41d4-a716-446655440001",
        "name": "Tata Power EZ Station - BKC",
        "city": "Mumbai",
        "latitude": 19.0602,
        "longitude": 72.8697,
        "rating": 4.2,
        "total_reviews": 15
      },
      "created_at": "2024-01-01T00:00:00.000Z"
    }
  ]
}
```

### Check Favorite

```
GET /api/favorites/check/:stationId
```

**Response `200`:**
```json
{
  "success": true,
  "data": {
    "is_favorite": true,
    "favorite_id": "880e8400-e29b-41d4-a716-446655440001"
  }
}
```

### Remove Favorite

```
DELETE /api/favorites/:id
```

**Response `200`:**
```json
{
  "success": true,
  "message": "Favorite removed successfully"
}
```

---

## Report Endpoints

### Create Report

```
POST /api/reports
```

**Auth:** Bearer token required

**Request body:**
```json
{
  "station_id": "550e8400-e29b-41d4-a716-446655440001",
  "report_type": "CHARGER_BROKEN",
  "description": "2 out of 4 CCS2 chargers are not working."
}
```

**Valid report types:** `CLOSED`, `WRONG_LOCATION`, `PRICING_ISSUE`, `CHARGER_BROKEN`

**Response `201`:**
```json
{
  "success": true,
  "data": {
    "id": "990e8400-e29b-41d4-a716-446655440001",
    "report_type": "CHARGER_BROKEN",
    "status": "PENDING",
    "created_at": "2024-01-01T00:00:00.000Z"
  }
}
```

### Get My Reports

```
GET /api/reports/my-reports
```

**Auth:** Bearer token required

Returns all reports by the authenticated user.

### Get All Reports (Admin)

```
GET /api/reports
```

**Auth:** Bearer token required — Admin only

Returns all reports across all stations.

### Update Report Status (Admin)

```
PUT /api/reports/:id
```

**Auth:** Bearer token required — Admin only

**Request body:**
```json
{
  "status": "RESOLVED",
  "admin_notes": "Service team has repaired the chargers."
}
```

**Valid statuses:** `PENDING`, `IN_REVIEW`, `RESOLVED`, `DISMISSED`

**Response `200`:**
```json
{
  "success": true,
  "data": {
    "id": "990e8400-e29b-41d4-a716-446655440001",
    "status": "RESOLVED",
    "admin_notes": "Service team has repaired the chargers.",
    "resolved_at": "2024-01-02T00:00:00.000Z"
  }
}
```

---

## HTTP Status Codes

| Code | Meaning |
|---|---|
| `200` | Success |
| `201` | Created |
| `400` | Bad request (invalid input) |
| `401` | Unauthorized (missing/invalid token) |
| `403` | Forbidden (insufficient permissions) |
| `404` | Not found |
| `409` | Conflict (duplicate resource) |
| `422` | Validation error |
| `429` | Rate limit exceeded |
| `500` | Internal server error |

## Common Error Codes

| Error | Status | Cause |
|---|---|---|
| `Access denied. No token provided.` | 401 | Missing Authorization header |
| `Token has expired.` | 401 | JWT expired |
| `Invalid token.` | 401 | Malformed or fake JWT |
| `Admin access required.` | 403 | Non-admin user on admin route |
| `Route not found` | 404 | Invalid endpoint |
| `Too many requests` | 429 | Rate limit hit |
| `An unexpected error occurred` | 500 | Server error (production) |
