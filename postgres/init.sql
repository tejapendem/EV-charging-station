-- Enable PostGIS extension
CREATE EXTENSION IF NOT EXISTS postgis;
CREATE EXTENSION IF NOT EXISTS postgis_topology;
CREATE EXTENSION IF NOT EXISTS fuzzystrmatch;
CREATE EXTENSION IF NOT EXISTS postgis_tiger_geocoder;

-- Create application user if not exists
DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'ev_connect_user') THEN
        CREATE ROLE ev_connect_user WITH LOGIN PASSWORD 'ev_connect_pass';
    END IF;
END
$$;

-- Create database if not exists
SELECT 'CREATE DATABASE ev_connect_india OWNER ev_connect_user'
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'ev_connect_india')\gexec

-- Grant privileges
GRANT ALL PRIVILEGES ON DATABASE ev_connect_india TO ev_connect_user;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO ev_connect_user;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO ev_connect_user;
GRANT ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA public TO ev_connect_user;

-- Grant PostGIS usage
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO ev_connect_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO ev_connect_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON FUNCTIONS TO ev_connect_user;
