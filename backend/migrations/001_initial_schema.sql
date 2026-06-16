-- EV Connect India - Database Schema
-- PostgreSQL (PostGIS optional, enabled if available)

-- ============================================================
-- EXTENSIONS
-- ============================================================
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ============================================================
-- ENUMS
-- ============================================================
DO $$ BEGIN
  CREATE TYPE charger_type_enum AS ENUM ('CCS2', 'Type2', 'CHAdeMO', 'Bharat_DC001', 'Bharat_AC001');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$ BEGIN
  CREATE TYPE speed_category_enum AS ENUM ('SLOW', 'FAST', 'ULTRA_FAST');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$ BEGIN
  CREATE TYPE station_status_enum AS ENUM ('ACTIVE', 'INACTIVE', 'UNDER_MAINTENANCE');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$ BEGIN
  CREATE TYPE connector_status_enum AS ENUM ('ACTIVE', 'INACTIVE', 'UNDER_MAINTENANCE');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$ BEGIN
  CREATE TYPE report_type_enum AS ENUM ('CLOSED', 'WRONG_LOCATION', 'PRICING_ISSUE', 'CHARGER_BROKEN');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$ BEGIN
  CREATE TYPE report_status_enum AS ENUM ('PENDING', 'IN_REVIEW', 'RESOLVED', 'DISMISSED');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$ BEGIN
  CREATE TYPE amenity_enum AS ENUM ('RESTROOMS', 'FOOD_COURT', 'HOTEL', 'WIFI', 'PARKING');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$ BEGIN
  CREATE TYPE user_role_enum AS ENUM ('user', 'admin', 'station_owner');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$ BEGIN
  CREATE TYPE auth_provider_enum AS ENUM ('email', 'google', 'apple');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

-- ============================================================
-- USERS TABLE
-- ============================================================
CREATE TABLE IF NOT EXISTS users (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  firebase_uid VARCHAR(128) UNIQUE,
  name VARCHAR(255) NOT NULL DEFAULT '',
  email VARCHAR(255) UNIQUE NOT NULL,
  phone VARCHAR(20),
  password_hash VARCHAR(255),
  avatar_url TEXT,
  role user_role_enum NOT NULL DEFAULT 'user',
  auth_provider auth_provider_enum NOT NULL DEFAULT 'email',
  fcm_token TEXT,
  is_verified BOOLEAN NOT NULL DEFAULT false,
  last_login TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_firebase_uid ON users(firebase_uid);
CREATE INDEX IF NOT EXISTS idx_users_role ON users(role);

-- ============================================================
-- CHARGING STATIONS TABLE
-- ============================================================
CREATE TABLE IF NOT EXISTS charging_stations (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name VARCHAR(255) NOT NULL,
  address TEXT NOT NULL,
  city VARCHAR(100) NOT NULL,
  state VARCHAR(100) NOT NULL,
  pincode VARCHAR(10),
  highway VARCHAR(255),
  landmark VARCHAR(255),
  latitude DECIMAL(10, 7),
  longitude DECIMAL(10, 7),
  phone VARCHAR(20),
  operating_hours TEXT,
  price_per_kwh DECIMAL(10, 2),
  status station_status_enum NOT NULL DEFAULT 'ACTIVE',
  image_url TEXT,
  is_verified BOOLEAN NOT NULL DEFAULT false,
  created_by UUID REFERENCES users(id) ON DELETE SET NULL,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_stations_coords ON charging_stations(latitude, longitude);
CREATE INDEX IF NOT EXISTS idx_stations_city ON charging_stations(city);
CREATE INDEX IF NOT EXISTS idx_stations_state ON charging_stations(state);
CREATE INDEX IF NOT EXISTS idx_stations_status ON charging_stations(status);
CREATE INDEX IF NOT EXISTS idx_stations_pincode ON charging_stations(pincode);
CREATE INDEX IF NOT EXISTS idx_stations_created_by ON charging_stations(created_by);

-- ============================================================
-- CHARGER TYPES TABLE
-- ============================================================
CREATE TABLE IF NOT EXISTS charger_types (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  station_id UUID NOT NULL REFERENCES charging_stations(id) ON DELETE CASCADE,
  charger_type charger_type_enum NOT NULL,
  power_output DECIMAL(10, 2),
  speed_category speed_category_enum NOT NULL DEFAULT 'SLOW',
  quantity INTEGER NOT NULL DEFAULT 1 CHECK (quantity > 0),
  price_per_kwh DECIMAL(10, 2),
  connector_status connector_status_enum NOT NULL DEFAULT 'ACTIVE',
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  UNIQUE(station_id, charger_type)
);

CREATE INDEX IF NOT EXISTS idx_charger_types_station ON charger_types(station_id);
CREATE INDEX IF NOT EXISTS idx_charger_types_type ON charger_types(charger_type);
CREATE INDEX IF NOT EXISTS idx_charger_types_speed ON charger_types(speed_category);

-- ============================================================
-- STATION AMENITIES TABLE
-- ============================================================
CREATE TABLE IF NOT EXISTS station_amenities (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  station_id UUID NOT NULL REFERENCES charging_stations(id) ON DELETE CASCADE,
  amenity amenity_enum NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  UNIQUE(station_id, amenity)
);

CREATE INDEX IF NOT EXISTS idx_amenities_station ON station_amenities(station_id);

-- ============================================================
-- STATION IMAGES TABLE
-- ============================================================
CREATE TABLE IF NOT EXISTS station_images (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  station_id UUID NOT NULL REFERENCES charging_stations(id) ON DELETE CASCADE,
  image_url TEXT NOT NULL,
  caption VARCHAR(255),
  is_primary BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_station_images_station ON station_images(station_id);

-- ============================================================
-- REVIEWS TABLE
-- ============================================================
CREATE TABLE IF NOT EXISTS reviews (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  station_id UUID NOT NULL REFERENCES charging_stations(id) ON DELETE CASCADE,
  rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
  comment TEXT,
  is_verified BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  UNIQUE(user_id, station_id)
);

CREATE INDEX IF NOT EXISTS idx_reviews_station ON reviews(station_id);
CREATE INDEX IF NOT EXISTS idx_reviews_user ON reviews(user_id);
CREATE INDEX IF NOT EXISTS idx_reviews_rating ON reviews(rating);

-- ============================================================
-- FAVORITES TABLE
-- ============================================================
CREATE TABLE IF NOT EXISTS favorites (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  station_id UUID NOT NULL REFERENCES charging_stations(id) ON DELETE CASCADE,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  UNIQUE(user_id, station_id)
);

CREATE INDEX IF NOT EXISTS idx_favorites_user ON favorites(user_id);
CREATE INDEX IF NOT EXISTS idx_favorites_station ON favorites(station_id);

-- ============================================================
-- REPORTS TABLE
-- ============================================================
CREATE TABLE IF NOT EXISTS reports (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  station_id UUID NOT NULL REFERENCES charging_stations(id) ON DELETE CASCADE,
  report_type report_type_enum NOT NULL,
  description TEXT,
  status report_status_enum NOT NULL DEFAULT 'PENDING',
  admin_notes TEXT,
  resolved_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_reports_user ON reports(user_id);
CREATE INDEX IF NOT EXISTS idx_reports_station ON reports(station_id);
CREATE INDEX IF NOT EXISTS idx_reports_status ON reports(status);
CREATE INDEX IF NOT EXISTS idx_reports_type ON reports(report_type);

-- ============================================================
-- NOTIFICATIONS TABLE
-- ============================================================
CREATE TABLE IF NOT EXISTS notifications (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  title VARCHAR(255) NOT NULL,
  body TEXT NOT NULL,
  data JSONB,
  is_read BOOLEAN NOT NULL DEFAULT false,
  sent_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  read_at TIMESTAMP WITH TIME ZONE
);

CREATE INDEX IF NOT EXISTS idx_notifications_user ON notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_notifications_read ON notifications(user_id, is_read);

-- ============================================================
-- FULL TEXT SEARCH INDEX
-- ============================================================
CREATE INDEX IF NOT EXISTS idx_stations_fts ON charging_stations USING GIN(
  to_tsvector('english', COALESCE(name, '') || ' ' ||
    COALESCE(address, '') || ' ' ||
    COALESCE(city, '') || ' ' ||
    COALESCE(state, '') || ' ' ||
    COALESCE(pincode, '') || ' ' ||
    COALESCE(highway, '') || ' ' ||
    COALESCE(landmark, ''))
);

-- ============================================================
-- TRIGGER: UPDATE UPDATED_AT
-- ============================================================
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_users_updated_at
  BEFORE UPDATE ON users
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trg_stations_updated_at
  BEFORE UPDATE ON charging_stations
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trg_charger_types_updated_at
  BEFORE UPDATE ON charger_types
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trg_reviews_updated_at
  BEFORE UPDATE ON reviews
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trg_reports_updated_at
  BEFORE UPDATE ON reports
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ============================================================
-- TRIGGER: AUTO-UPDATE STATION RATING
-- ============================================================
CREATE OR REPLACE FUNCTION update_station_rating()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE charging_stations
  SET updated_at = NOW()
  WHERE id = NEW.station_id;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_review_update_station
  AFTER INSERT OR UPDATE OR DELETE ON reviews
  FOR EACH ROW EXECUTE FUNCTION update_station_rating();

-- ============================================================
-- SEED ADMIN USER (password: admin123, update in production)
-- ============================================================
INSERT INTO users (name, email, password_hash, role, auth_provider, is_verified)
VALUES (
  'Admin',
  'admin@evconnectindia.com',
  '$2a$12$LJ3m4ys3Lg3YOCwKkq5aYuqRZNb1vFMm2mF9tQFn1mX5X5X5X5X5X',
  'admin',
  'email',
  true
) ON CONFLICT (email) DO NOTHING;
