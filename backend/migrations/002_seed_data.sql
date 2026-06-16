-- EV Connect India - Seed Data
-- Sample EV charging stations across major Indian cities

INSERT INTO charging_stations (name, address, city, state, pincode, highway, landmark, latitude, longitude, phone, operating_hours, price_per_kwh, status, is_verified)
VALUES
  ('Tata Power EZ Station - BKC', 'Ground Floor, Platina Building, Bandra Kurla Complex', 'Mumbai', 'Maharashtra', '400051', 'Western Express Highway', 'Near BKC Signal', 19.0602, 72.8697, '+91-22-6789-1000', '24/7', 12.50, 'ACTIVE', true),
  ('EESL EV Charging Hub - CP', 'Outer Circle, Connaught Place, Near State Bank of India', 'New Delhi', 'Delhi', '110001', 'Inner Ring Road', 'Near Rajiv Chowk Metro Station', 28.6304, 77.2090, '+91-11-4567-8901', '06:00 - 23:00', 10.00, 'ACTIVE', true),
  ('ChargeGrid - MG Road', '1 MG Road, Near Bangalore Club, Ashok Nagar', 'Bengaluru', 'Karnataka', '560001', 'MG Road', 'Near Trinity Metro Station', 12.9716, 77.6065, '+91-80-2345-6789', '24/7', 11.00, 'ACTIVE', true),
  ('Volttic Fast Chargers - HITEC City', 'Plot 25, Phase 2, HITEC City, Near Cyber Towers', 'Hyderabad', 'Telangana', '500081', 'NH 65', 'Near Cyber Towers', 17.4413, 78.3750, '+91-40-3456-7890', '07:00 - 22:00', 13.00, 'ACTIVE', true),
  ('Zeon Charging Hub - OMR', 'OMR Road, Near Thoraipakkam Toll Plaza', 'Chennai', 'Tamil Nadu', '600097', 'IT Expressway (OMR)', 'Near Thoraipakkam Toll', 12.8231, 80.2697, '+91-44-5678-9012', '06:00 - 23:00', 9.50, 'ACTIVE', true),
  ('Fortum Charge & Drive - Koregaon Park', 'Lane 5, Koregaon Park, Near Osho Garden', 'Pune', 'Maharashtra', '411001', 'Mumbai-Pune Highway', 'Near Osho Garden', 18.5913, 73.7320, '+91-20-6789-0123', '24/7', 11.50, 'ACTIVE', true),
  ('Adani Electricity - SG Highway', 'SG Highway, Near Prahlad Nagar Garden', 'Ahmedabad', 'Gujarat', '380015', 'SG Highway (NH 48)', 'Near Prahlad Nagar', 23.0705, 72.5582, '+91-79-7890-1234', '07:00 - 23:00', 10.50, 'ACTIVE', true),
  ('BPCL EV Station - Salt Lake', 'Sector 5, Salt Lake City, Near Central Park', 'Kolkata', 'West Bengal', '700091', 'Eastern Metropolitan Bypass', 'Near Central Park', 22.5800, 88.4333, '+91-33-8901-2345', '07:00 - 22:00', 10.00, 'ACTIVE', true),
  ('JBM Auto EV Hub - MI Road', 'MI Road, Near Jaipur Railway Station', 'Jaipur', 'Rajasthan', '302001', 'NH 11', 'Near Railway Station', 26.9124, 75.7873, '+91-141-9012-3456', '06:00 - 22:00', 11.00, 'ACTIVE', true),
  ('Ola Electric Hypercharger - Gomti Nagar', 'VIP Road, Gomti Nagar, Near Bhootnath Market', 'Lucknow', 'Uttar Pradesh', '226010', 'Lucknow-Kanpur Highway', 'Near Bhootnath Market', 26.8467, 80.9462, '+91-522-0123-4567', '24/7', 12.00, 'ACTIVE', true),
  ('Gujarat Gas EV Station - City Light', 'City Light Road, Near Yogichowk', 'Surat', 'Gujarat', '395007', 'Surat-Dandi Highway', 'Near Yogichowk Signal', 21.1702, 72.8311, '+91-261-1234-5678', '07:00 - 23:00', 9.00, 'ACTIVE', true),
  ('Panasonic Life Solutions - Sector 8', 'Sector 8, Near Chandigarh IT Park', 'Chandigarh', 'Chandigarh', '160008', 'GT Road (NH 44)', 'Near IT Park', 30.7333, 76.7794, '+91-172-2345-6789', '24/7', 10.00, 'ACTIVE', true);

-- Amenities for each station
INSERT INTO station_amenities (station_id, amenity)
SELECT id, 'RESTROOMS' FROM charging_stations WHERE name = 'Tata Power EZ Station - BKC';
INSERT INTO station_amenities (station_id, amenity)
SELECT id, 'WIFI' FROM charging_stations WHERE name = 'Tata Power EZ Station - BKC';
INSERT INTO station_amenities (station_id, amenity)
SELECT id, 'PARKING' FROM charging_stations WHERE name = 'Tata Power EZ Station - BKC';

INSERT INTO station_amenities (station_id, amenity)
SELECT id, 'RESTROOMS' FROM charging_stations WHERE name = 'EESL EV Charging Hub - CP';
INSERT INTO station_amenities (station_id, amenity)
SELECT id, 'FOOD_COURT' FROM charging_stations WHERE name = 'EESL EV Charging Hub - CP';
INSERT INTO station_amenities (station_id, amenity)
SELECT id, 'PARKING' FROM charging_stations WHERE name = 'EESL EV Charging Hub - CP';

INSERT INTO station_amenities (station_id, amenity)
SELECT id, 'RESTROOMS' FROM charging_stations WHERE name = 'ChargeGrid - MG Road';
INSERT INTO station_amenities (station_id, amenity)
SELECT id, 'WIFI' FROM charging_stations WHERE name = 'ChargeGrid - MG Road';
INSERT INTO station_amenities (station_id, amenity)
SELECT id, 'FOOD_COURT' FROM charging_stations WHERE name = 'ChargeGrid - MG Road';
INSERT INTO station_amenities (station_id, amenity)
SELECT id, 'PARKING' FROM charging_stations WHERE name = 'ChargeGrid - MG Road';

INSERT INTO station_amenities (station_id, amenity)
SELECT id, 'RESTROOMS' FROM charging_stations WHERE name = 'Volttic Fast Chargers - HITEC City';
INSERT INTO station_amenities (station_id, amenity)
SELECT id, 'WIFI' FROM charging_stations WHERE name = 'Volttic Fast Chargers - HITEC City';
INSERT INTO station_amenities (station_id, amenity)
SELECT id, 'PARKING' FROM charging_stations WHERE name = 'Volttic Fast Chargers - HITEC City';

INSERT INTO station_amenities (station_id, amenity)
SELECT id, 'RESTROOMS' FROM charging_stations WHERE name = 'Zeon Charging Hub - OMR';
INSERT INTO station_amenities (station_id, amenity)
SELECT id, 'FOOD_COURT' FROM charging_stations WHERE name = 'Zeon Charging Hub - OMR';
INSERT INTO station_amenities (station_id, amenity)
SELECT id, 'PARKING' FROM charging_stations WHERE name = 'Zeon Charging Hub - OMR';

INSERT INTO station_amenities (station_id, amenity)
SELECT id, 'RESTROOMS' FROM charging_stations WHERE name = 'Fortum Charge & Drive - Koregaon Park';
INSERT INTO station_amenities (station_id, amenity)
SELECT id, 'HOTEL' FROM charging_stations WHERE name = 'Fortum Charge & Drive - Koregaon Park';
INSERT INTO station_amenities (station_id, amenity)
SELECT id, 'WIFI' FROM charging_stations WHERE name = 'Fortum Charge & Drive - Koregaon Park';
INSERT INTO station_amenities (station_id, amenity)
SELECT id, 'PARKING' FROM charging_stations WHERE name = 'Fortum Charge & Drive - Koregaon Park';

INSERT INTO station_amenities (station_id, amenity)
SELECT id, 'RESTROOMS' FROM charging_stations WHERE name = 'Adani Electricity - SG Highway';
INSERT INTO station_amenities (station_id, amenity)
SELECT id, 'FOOD_COURT' FROM charging_stations WHERE name = 'Adani Electricity - SG Highway';
INSERT INTO station_amenities (station_id, amenity)
SELECT id, 'PARKING' FROM charging_stations WHERE name = 'Adani Electricity - SG Highway';

INSERT INTO station_amenities (station_id, amenity)
SELECT id, 'RESTROOMS' FROM charging_stations WHERE name = 'BPCL EV Station - Salt Lake';
INSERT INTO station_amenities (station_id, amenity)
SELECT id, 'WIFI' FROM charging_stations WHERE name = 'BPCL EV Station - Salt Lake';
INSERT INTO station_amenities (station_id, amenity)
SELECT id, 'PARKING' FROM charging_stations WHERE name = 'BPCL EV Station - Salt Lake';

INSERT INTO station_amenities (station_id, amenity)
SELECT id, 'RESTROOMS' FROM charging_stations WHERE name = 'JBM Auto EV Hub - MI Road';
INSERT INTO station_amenities (station_id, amenity)
SELECT id, 'FOOD_COURT' FROM charging_stations WHERE name = 'JBM Auto EV Hub - MI Road';
INSERT INTO station_amenities (station_id, amenity)
SELECT id, 'PARKING' FROM charging_stations WHERE name = 'JBM Auto EV Hub - MI Road';

INSERT INTO station_amenities (station_id, amenity)
SELECT id, 'RESTROOMS' FROM charging_stations WHERE name = 'Ola Electric Hypercharger - Gomti Nagar';
INSERT INTO station_amenities (station_id, amenity)
SELECT id, 'WIFI' FROM charging_stations WHERE name = 'Ola Electric Hypercharger - Gomti Nagar';
INSERT INTO station_amenities (station_id, amenity)
SELECT id, 'PARKING' FROM charging_stations WHERE name = 'Ola Electric Hypercharger - Gomti Nagar';

INSERT INTO station_amenities (station_id, amenity)
SELECT id, 'RESTROOMS' FROM charging_stations WHERE name = 'Gujarat Gas EV Station - City Light';
INSERT INTO station_amenities (station_id, amenity)
SELECT id, 'PARKING' FROM charging_stations WHERE name = 'Gujarat Gas EV Station - City Light';

INSERT INTO station_amenities (station_id, amenity)
SELECT id, 'RESTROOMS' FROM charging_stations WHERE name = 'Panasonic Life Solutions - Sector 8';
INSERT INTO station_amenities (station_id, amenity)
SELECT id, 'WIFI' FROM charging_stations WHERE name = 'Panasonic Life Solutions - Sector 8';
INSERT INTO station_amenities (station_id, amenity)
SELECT id, 'PARKING' FROM charging_stations WHERE name = 'Panasonic Life Solutions - Sector 8';

-- Charger types for each station
INSERT INTO charger_types (station_id, charger_type, power_output, speed_category, quantity, price_per_kwh, connector_status)
SELECT id, 'CCS2', 150.00, 'ULTRA_FAST', 4, 12.50, 'ACTIVE' FROM charging_stations WHERE name = 'Tata Power EZ Station - BKC';
INSERT INTO charger_types (station_id, charger_type, power_output, speed_category, quantity, price_per_kwh, connector_status)
SELECT id, 'Type2', 22.00, 'FAST', 2, 10.00, 'ACTIVE' FROM charging_stations WHERE name = 'Tata Power EZ Station - BKC';
INSERT INTO charger_types (station_id, charger_type, power_output, speed_category, quantity, price_per_kwh, connector_status)
SELECT id, 'CHAdeMO', 50.00, 'FAST', 2, 12.50, 'ACTIVE' FROM charging_stations WHERE name = 'Tata Power EZ Station - BKC';

INSERT INTO charger_types (station_id, charger_type, power_output, speed_category, quantity, price_per_kwh, connector_status)
SELECT id, 'CCS2', 60.00, 'FAST', 3, 10.00, 'ACTIVE' FROM charging_stations WHERE name = 'EESL EV Charging Hub - CP';
INSERT INTO charger_types (station_id, charger_type, power_output, speed_category, quantity, price_per_kwh, connector_status)
SELECT id, 'Type2', 22.00, 'FAST', 4, 8.00, 'ACTIVE' FROM charging_stations WHERE name = 'EESL EV Charging Hub - CP';
INSERT INTO charger_types (station_id, charger_type, power_output, speed_category, quantity, price_per_kwh, connector_status)
SELECT id, 'Bharat_DC001', 15.00, 'SLOW', 2, 6.00, 'ACTIVE' FROM charging_stations WHERE name = 'EESL EV Charging Hub - CP';

INSERT INTO charger_types (station_id, charger_type, power_output, speed_category, quantity, price_per_kwh, connector_status)
SELECT id, 'CCS2', 120.00, 'ULTRA_FAST', 4, 11.00, 'ACTIVE' FROM charging_stations WHERE name = 'ChargeGrid - MG Road';
INSERT INTO charger_types (station_id, charger_type, power_output, speed_category, quantity, price_per_kwh, connector_status)
SELECT id, 'Type2', 22.00, 'FAST', 3, 9.00, 'ACTIVE' FROM charging_stations WHERE name = 'ChargeGrid - MG Road';
INSERT INTO charger_types (station_id, charger_type, power_output, speed_category, quantity, price_per_kwh, connector_status)
SELECT id, 'CHAdeMO', 50.00, 'FAST', 2, 10.50, 'ACTIVE' FROM charging_stations WHERE name = 'ChargeGrid - MG Road';

INSERT INTO charger_types (station_id, charger_type, power_output, speed_category, quantity, price_per_kwh, connector_status)
SELECT id, 'CCS2', 100.00, 'FAST', 3, 13.00, 'ACTIVE' FROM charging_stations WHERE name = 'Volttic Fast Chargers - HITEC City';
INSERT INTO charger_types (station_id, charger_type, power_output, speed_category, quantity, price_per_kwh, connector_status)
SELECT id, 'Type2', 22.00, 'FAST', 2, 10.00, 'ACTIVE' FROM charging_stations WHERE name = 'Volttic Fast Chargers - HITEC City';

INSERT INTO charger_types (station_id, charger_type, power_output, speed_category, quantity, price_per_kwh, connector_status)
SELECT id, 'CCS2', 50.00, 'FAST', 2, 9.50, 'ACTIVE' FROM charging_stations WHERE name = 'Zeon Charging Hub - OMR';
INSERT INTO charger_types (station_id, charger_type, power_output, speed_category, quantity, price_per_kwh, connector_status)
SELECT id, 'Type2', 22.00, 'FAST', 3, 7.50, 'ACTIVE' FROM charging_stations WHERE name = 'Zeon Charging Hub - OMR';
INSERT INTO charger_types (station_id, charger_type, power_output, speed_category, quantity, price_per_kwh, connector_status)
SELECT id, 'Bharat_AC001', 3.30, 'SLOW', 4, 5.00, 'ACTIVE' FROM charging_stations WHERE name = 'Zeon Charging Hub - OMR';

INSERT INTO charger_types (station_id, charger_type, power_output, speed_category, quantity, price_per_kwh, connector_status)
SELECT id, 'CCS2', 100.00, 'FAST', 4, 11.50, 'ACTIVE' FROM charging_stations WHERE name = 'Fortum Charge & Drive - Koregaon Park';
INSERT INTO charger_types (station_id, charger_type, power_output, speed_category, quantity, price_per_kwh, connector_status)
SELECT id, 'Type2', 22.00, 'FAST', 2, 9.00, 'ACTIVE' FROM charging_stations WHERE name = 'Fortum Charge & Drive - Koregaon Park';
INSERT INTO charger_types (station_id, charger_type, power_output, speed_category, quantity, price_per_kwh, connector_status)
SELECT id, 'CHAdeMO', 50.00, 'FAST', 2, 11.00, 'ACTIVE' FROM charging_stations WHERE name = 'Fortum Charge & Drive - Koregaon Park';

INSERT INTO charger_types (station_id, charger_type, power_output, speed_category, quantity, price_per_kwh, connector_status)
SELECT id, 'CCS2', 60.00, 'FAST', 3, 10.50, 'ACTIVE' FROM charging_stations WHERE name = 'Adani Electricity - SG Highway';
INSERT INTO charger_types (station_id, charger_type, power_output, speed_category, quantity, price_per_kwh, connector_status)
SELECT id, 'Type2', 22.00, 'FAST', 4, 8.50, 'ACTIVE' FROM charging_stations WHERE name = 'Adani Electricity - SG Highway';

INSERT INTO charger_types (station_id, charger_type, power_output, speed_category, quantity, price_per_kwh, connector_status)
SELECT id, 'CCS2', 60.00, 'FAST', 3, 10.00, 'ACTIVE' FROM charging_stations WHERE name = 'BPCL EV Station - Salt Lake';
INSERT INTO charger_types (station_id, charger_type, power_output, speed_category, quantity, price_per_kwh, connector_status)
SELECT id, 'Type2', 22.00, 'FAST', 2, 8.00, 'ACTIVE' FROM charging_stations WHERE name = 'BPCL EV Station - Salt Lake';
INSERT INTO charger_types (station_id, charger_type, power_output, speed_category, quantity, price_per_kwh, connector_status)
SELECT id, 'Bharat_DC001', 15.00, 'SLOW', 2, 6.00, 'ACTIVE' FROM charging_stations WHERE name = 'BPCL EV Station - Salt Lake';

INSERT INTO charger_types (station_id, charger_type, power_output, speed_category, quantity, price_per_kwh, connector_status)
SELECT id, 'CCS2', 50.00, 'FAST', 2, 11.00, 'ACTIVE' FROM charging_stations WHERE name = 'JBM Auto EV Hub - MI Road';
INSERT INTO charger_types (station_id, charger_type, power_output, speed_category, quantity, price_per_kwh, connector_status)
SELECT id, 'Type2', 22.00, 'FAST', 3, 9.00, 'ACTIVE' FROM charging_stations WHERE name = 'JBM Auto EV Hub - MI Road';

INSERT INTO charger_types (station_id, charger_type, power_output, speed_category, quantity, price_per_kwh, connector_status)
SELECT id, 'CCS2', 150.00, 'ULTRA_FAST', 4, 12.00, 'ACTIVE' FROM charging_stations WHERE name = 'Ola Electric Hypercharger - Gomti Nagar';
INSERT INTO charger_types (station_id, charger_type, power_output, speed_category, quantity, price_per_kwh, connector_status)
SELECT id, 'Type2', 22.00, 'FAST', 2, 9.50, 'ACTIVE' FROM charging_stations WHERE name = 'Ola Electric Hypercharger - Gomti Nagar';

INSERT INTO charger_types (station_id, charger_type, power_output, speed_category, quantity, price_per_kwh, connector_status)
SELECT id, 'CCS2', 50.00, 'FAST', 2, 9.00, 'ACTIVE' FROM charging_stations WHERE name = 'Gujarat Gas EV Station - City Light';
INSERT INTO charger_types (station_id, charger_type, power_output, speed_category, quantity, price_per_kwh, connector_status)
SELECT id, 'Type2', 22.00, 'FAST', 2, 7.00, 'ACTIVE' FROM charging_stations WHERE name = 'Gujarat Gas EV Station - City Light';
INSERT INTO charger_types (station_id, charger_type, power_output, speed_category, quantity, price_per_kwh, connector_status)
SELECT id, 'Bharat_AC001', 3.30, 'SLOW', 2, 5.00, 'ACTIVE' FROM charging_stations WHERE name = 'Gujarat Gas EV Station - City Light';

INSERT INTO charger_types (station_id, charger_type, power_output, speed_category, quantity, price_per_kwh, connector_status)
SELECT id, 'CCS2', 60.00, 'FAST', 3, 10.00, 'ACTIVE' FROM charging_stations WHERE name = 'Panasonic Life Solutions - Sector 8';
INSERT INTO charger_types (station_id, charger_type, power_output, speed_category, quantity, price_per_kwh, connector_status)
SELECT id, 'Type2', 22.00, 'FAST', 2, 8.00, 'ACTIVE' FROM charging_stations WHERE name = 'Panasonic Life Solutions - Sector 8';
