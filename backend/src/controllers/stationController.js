import { query } from '../config/database.js';
import { geocodeAddress } from '../services/geocodingService.js';
import { buildSuccessResponse, buildErrorResponse, paginate } from '../utils/helpers.js';

export const createStation = async (req, res) => {
  try {
    const {
      name,
      address,
      city,
      state,
      pincode,
      latitude,
      longitude,
      phone,
      operating_hours,
      price_per_kwh,
      status,
      amenities: amenitiesArr,
      chargers,
      highway,
      landmark,
    } = req.body;

    let finalLat = latitude;
    let finalLng = longitude;

    if (!finalLat || !finalLng) {
      const geocoded = await geocodeAddress(`${name}, ${address}, ${city}, ${state}`);
      finalLat = geocoded.latitude;
      finalLng = geocoded.longitude;
    }

    const stationResult = await query(
      `INSERT INTO charging_stations (
        name, address, city, state, pincode, highway, landmark,
        latitude, longitude, phone, operating_hours,
        price_per_kwh, status, created_by, image_url
      ) VALUES (
        $1, $2, $3, $4, $5, $6, $7,
        $8, $9, $10, $11, $12, $13, $14, $15, $16
      )
      RETURNING *`,
      [
        name, address, city, state, pincode || null, highway || null, landmark || null,
        finalLat, finalLng,
        phone || null, operating_hours || null,
        price_per_kwh || null, status || 'ACTIVE',
        req.user.id, req.file ? `/uploads/${req.file.filename}` : null,
      ]
    );

    const station = stationResult.rows[0];

    if (amenitiesArr && Array.isArray(amenitiesArr) && amenitiesArr.length > 0) {
      for (const amenity of amenitiesArr) {
        const validAmenities = ['RESTROOMS', 'FOOD_COURT', 'HOTEL', 'WIFI', 'PARKING'];
        if (validAmenities.includes(amenity)) {
          await query(
            'INSERT INTO station_amenities (station_id, amenity) VALUES ($1, $2) ON CONFLICT DO NOTHING',
            [station.id, amenity]
          );
        }
      }
    }

    if (chargers && Array.isArray(chargers) && chargers.length > 0) {
      for (const charger of chargers) {
        const validTypes = ['CCS2', 'Type2', 'CHAdeMO', 'Bharat_DC001', 'Bharat_AC001'];
        if (validTypes.includes(charger.charger_type)) {
          const speedCategory = getSpeedCategory(charger.power_output);
          await query(
            `INSERT INTO charger_types (station_id, charger_type, power_output, speed_category, quantity, price_per_kwh, connector_status)
             VALUES ($1, $2, $3, $4, $5, $6, $7)`,
            [
              station.id,
              charger.charger_type,
              charger.power_output || null,
              speedCategory,
              charger.quantity || 1,
              charger.price_per_kwh || null,
              charger.connector_status || 'ACTIVE',
            ]
          );
        }
      }
    }

    const fullStation = await getStationById(station.id);

    return res.status(201).json(buildSuccessResponse(fullStation, 'Station created successfully'));
  } catch (error) {
    console.error('Create station error:', error);
    return res.status(500).json(buildErrorResponse('Failed to create station.', 500));
  }
};

export const getStation = async (req, res) => {
  try {
    const { id } = req.params;
    const station = await getStationById(id);

    if (!station) {
      return res.status(404).json(buildErrorResponse('Station not found.', 404));
    }

    const reviewStats = await query(
      `SELECT
        COUNT(*)::int AS total_reviews,
        COALESCE(ROUND(AVG(rating), 1), 0)::float AS average_rating,
        COUNT(*) FILTER (WHERE rating = 5)::int AS five_star,
        COUNT(*) FILTER (WHERE rating = 4)::int AS four_star,
        COUNT(*) FILTER (WHERE rating = 3)::int AS three_star,
        COUNT(*) FILTER (WHERE rating = 2)::int AS two_star,
        COUNT(*) FILTER (WHERE rating = 1)::int AS one_star
       FROM reviews WHERE station_id = $1 AND is_verified = true`,
      [id]
    );
    station.reviewStats = reviewStats.rows[0];

    return res.status(200).json(buildSuccessResponse(station, 'Station retrieved'));
  } catch (error) {
    console.error('Get station error:', error);
    return res.status(500).json(buildErrorResponse('Failed to retrieve station.', 500));
  }
};

export const updateStation = async (req, res) => {
  try {
    const { id } = req.params;

    const existing = await query('SELECT * FROM charging_stations WHERE id = $1', [id]);
    if (existing.rows.length === 0) {
      return res.status(404).json(buildErrorResponse('Station not found.', 404));
    }

    const {
      name, address, city, state, pincode, highway, landmark,
      latitude, longitude, phone, operating_hours,
      price_per_kwh, status, amenities, chargers,
    } = req.body;

    const updateFields = [];
    const updateValues = [];
    let paramIndex = 1;

    const fields = { name, address, city, state, pincode, highway, landmark, phone, operating_hours, price_per_kwh, status };
    for (const [key, value] of Object.entries(fields)) {
      if (value !== undefined) {
        updateFields.push(`${key} = $${paramIndex++}`);
        updateValues.push(value);
      }
    }

    if (latitude && longitude) {
      updateFields.push(`latitude = $${paramIndex}`);
      updateFields.push(`longitude = $${paramIndex + 1}`);
      paramIndex += 2;
      updateValues.push(latitude, longitude);
    }

    if (req.file) {
      updateFields.push(`image_url = $${paramIndex++}`);
      updateValues.push(`/uploads/${req.file.filename}`);
    }

    if (updateFields.length > 0) {
      updateFields.push('updated_at = NOW()');
      updateValues.push(id);
      await query(
        `UPDATE charging_stations SET ${updateFields.join(', ')} WHERE id = $${paramIndex}`,
        updateValues
      );
    }

    if (amenities && Array.isArray(amenities)) {
      await query('DELETE FROM station_amenities WHERE station_id = $1', [id]);
      const validAmenities = ['RESTROOMS', 'FOOD_COURT', 'HOTEL', 'WIFI', 'PARKING'];
      for (const amenity of amenities) {
        if (validAmenities.includes(amenity)) {
          await query('INSERT INTO station_amenities (station_id, amenity) VALUES ($1, $2) ON CONFLICT DO NOTHING', [id, amenity]);
        }
      }
    }

    if (chargers && Array.isArray(chargers)) {
      await query('DELETE FROM charger_types WHERE station_id = $1', [id]);
      const validTypes = ['CCS2', 'Type2', 'CHAdeMO', 'Bharat_DC001', 'Bharat_AC001'];
      for (const charger of chargers) {
        if (validTypes.includes(charger.charger_type)) {
          const speedCategory = getSpeedCategory(charger.power_output);
          await query(
            `INSERT INTO charger_types (station_id, charger_type, power_output, speed_category, quantity, price_per_kwh, connector_status)
             VALUES ($1, $2, $3, $4, $5, $6, $7)`,
            [id, charger.charger_type, charger.power_output || null, speedCategory, charger.quantity || 1, charger.price_per_kwh || null, charger.connector_status || 'ACTIVE']
          );
        }
      }
    }

    const updatedStation = await getStationById(id);
    return res.status(200).json(buildSuccessResponse(updatedStation, 'Station updated successfully'));
  } catch (error) {
    console.error('Update station error:', error);
    return res.status(500).json(buildErrorResponse('Failed to update station.', 500));
  }
};

export const deleteStation = async (req, res) => {
  try {
    const { id } = req.params;

    const existing = await query('SELECT id FROM charging_stations WHERE id = $1', [id]);
    if (existing.rows.length === 0) {
      return res.status(404).json(buildErrorResponse('Station not found.', 404));
    }

    await query('DELETE FROM charging_stations WHERE id = $1', [id]);

    return res.status(200).json(buildSuccessResponse(null, 'Station deleted successfully'));
  } catch (error) {
    console.error('Delete station error:', error);
    return res.status(500).json(buildErrorResponse('Failed to delete station.', 500));
  }
};

export const getNearbyStations = async (req, res) => {
  try {
    const { lat, lng, radius = 10, limit: queryLimit, page: queryPage } = req.query;

    const latitude = parseFloat(lat);
    const longitude = parseFloat(lng);
    const radiusKm = parseFloat(radius);

    if (isNaN(latitude) || isNaN(longitude)) {
      return res.status(400).json(buildErrorResponse('Valid latitude and longitude are required.', 400));
    }

    const { page, limit } = paginate(queryPage, queryLimit);

    const haversineSql = `
      6371 * 2 * ASIN(SQRT(
        POWER(SIN(RADIANS(latitude - $1) / 2), 2) +
        COS(RADIANS($1)) * COS(RADIANS(latitude)) *
        POWER(SIN(RADIANS(longitude - $2) / 2), 2)
      ))
    `;

    const countResult = await query(
      `SELECT COUNT(*)::int AS total
       FROM charging_stations
       WHERE status = 'ACTIVE'
         AND ${haversineSql} <= $3`,
      [latitude, longitude, radiusKm]
    );

    const stationsResult = await query(
      `SELECT
        id, name, address, city, state, pincode, highway, landmark,
        latitude, longitude,
        phone, operating_hours, price_per_kwh, status,
        image_url, is_verified,
        ROUND((${haversineSql})::numeric, 2) AS distance_km,
        created_at, updated_at
       FROM charging_stations
       WHERE status = 'ACTIVE'
         AND ${haversineSql} <= $3
       ORDER BY distance_km ASC
       LIMIT $4 OFFSET $5`,
      [latitude, longitude, radiusKm, limit, (page - 1) * limit]
    );

    const stations = await Promise.all(stationsResult.rows.map(async (station) => {
      const chargers = await query('SELECT * FROM charger_types WHERE station_id = $1', [station.id]);
      const amenities = await query('SELECT amenity FROM station_amenities WHERE station_id = $1', [station.id]);
      const avgRating = await query(
        'SELECT COALESCE(ROUND(AVG(rating), 1), 0)::float AS avg_rating, COUNT(*)::int AS total_reviews FROM reviews WHERE station_id = $1 AND is_verified = true',
        [station.id]
      );
      return { ...station, chargers: chargers.rows, amenities: amenities.rows.map(a => a.amenity), ...avgRating.rows[0] };
    }));

    const totalPages = Math.ceil(countResult.rows[0].total / limit);

    return res.status(200).json(buildSuccessResponse({
      stations,
      pagination: { page, limit, total: countResult.rows[0].total, totalPages },
    }, 'Nearby stations retrieved'));
  } catch (error) {
    console.error('Nearby stations error:', error);
    return res.status(500).json(buildErrorResponse('Failed to retrieve nearby stations.', 500));
  }
};

export const searchStations = async (req, res) => {
  try {
    const { q, city, state, charger_type, status, min_power, max_price } = req.query;

    if (!q && !city && !state && !charger_type) {
      return res.status(400).json(buildErrorResponse('Search query, city, state, or charger type is required.', 400));
    }

    const conditions = [];
    const params = [];
    let paramIndex = 1;

    if (q) {
      conditions.push(`(
        s.name ILIKE $${paramIndex} OR
        s.address ILIKE $${paramIndex} OR
        s.city ILIKE $${paramIndex} OR
        s.state ILIKE $${paramIndex} OR
        s.pincode ILIKE $${paramIndex} OR
        s.highway ILIKE $${paramIndex} OR
        s.landmark ILIKE $${paramIndex}
      )`);
      params.push(`%${q}%`);
      paramIndex++;
    }

    if (city) {
      conditions.push(`s.city ILIKE $${paramIndex}`);
      params.push(`%${city}%`);
      paramIndex++;
    }

    if (state) {
      conditions.push(`s.state ILIKE $${paramIndex}`);
      params.push(`%${state}%`);
      paramIndex++;
    }

    if (status) {
      conditions.push(`s.status = $${paramIndex}`);
      params.push(status);
      paramIndex++;
    }

    if (charger_type) {
      conditions.push(`ct.charger_type = $${paramIndex}`);
      params.push(charger_type);
      paramIndex++;
    }

    if (min_power) {
      conditions.push(`ct.power_output >= $${paramIndex}`);
      params.push(parseFloat(min_power));
      paramIndex++;
    }

    if (max_price) {
      conditions.push(`s.price_per_kwh <= $${paramIndex}`);
      params.push(parseFloat(max_price));
      paramIndex++;
    }

    const whereClause = conditions.length > 0 ? `WHERE ${conditions.join(' AND ')}` : '';

    const countResult = await query(
      `SELECT COUNT(DISTINCT s.id)::int AS total
       FROM charging_stations s
       LEFT JOIN charger_types ct ON ct.station_id = s.id
       ${whereClause}`,
      params
    );

    const stationsResult = await query(
      `SELECT DISTINCT ON (s.id)
        s.id, s.name, s.address, s.city, s.state, s.pincode,
        s.highway, s.landmark, s.latitude, s.longitude,
        s.phone, s.operating_hours, s.price_per_kwh, s.status,
        s.image_url, s.is_verified, s.created_at, s.updated_at
       FROM charging_stations s
       LEFT JOIN charger_types ct ON ct.station_id = s.id
       ${whereClause}
       ORDER BY s.id, s.name ASC
       LIMIT $${paramIndex} OFFSET $${paramIndex + 1}`,
      [...params, 20, 0]
    );

    const stations = await Promise.all(stationsResult.rows.map(async (station) => {
      const chargers = await query('SELECT * FROM charger_types WHERE station_id = $1', [station.id]);
      const amenities = await query('SELECT amenity FROM station_amenities WHERE station_id = $1', [station.id]);
      const avgRating = await query(
        'SELECT COALESCE(ROUND(AVG(rating), 1), 0)::float AS avg_rating, COUNT(*)::int AS total_reviews FROM reviews WHERE station_id = $1 AND is_verified = true',
        [station.id]
      );
      return { ...station, chargers: chargers.rows, amenities: amenities.rows.map(a => a.amenity), ...avgRating.rows[0] };
    }));

    return res.status(200).json(buildSuccessResponse({
      stations,
      pagination: { page: 1, limit: 20, total: countResult.rows[0].total, totalPages: Math.ceil(countResult.rows[0].total / 20) },
    }, 'Search results retrieved'));
  } catch (error) {
    console.error('Search stations error:', error);
    return res.status(500).json(buildErrorResponse('Failed to search stations.', 500));
  }
};

export const getStationChargers = async (req, res) => {
  try {
    const { id } = req.params;

    const stationExists = await query('SELECT id FROM charging_stations WHERE id = $1', [id]);
    if (stationExists.rows.length === 0) {
      return res.status(404).json(buildErrorResponse('Station not found.', 404));
    }

    const chargers = await query(
      'SELECT * FROM charger_types WHERE station_id = $1 ORDER BY charger_type',
      [id]
    );

    return res.status(200).json(buildSuccessResponse({ chargers: chargers.rows }, 'Chargers retrieved'));
  } catch (error) {
    console.error('Get chargers error:', error);
    return res.status(500).json(buildErrorResponse('Failed to retrieve chargers.', 500));
  }
};

export const getAllStations = async (req, res) => {
  try {
    const { page: queryPage, limit: queryLimit, status: filterStatus } = req.query;
    const { page, limit } = paginate(queryPage, queryLimit);

    let statusCondition = '';
    const params = [limit, (page - 1) * limit];
    if (filterStatus) {
      statusCondition = 'WHERE s.status = $3';
      params.push(filterStatus);
    }

    const countResult = await query(`SELECT COUNT(*)::int AS total FROM charging_stations s ${statusCondition}`,
      filterStatus ? [filterStatus] : []
    );

    const stationsResult = await query(
      `SELECT s.*, u.name AS created_by_name
       FROM charging_stations s
       LEFT JOIN users u ON u.id = s.created_by
       ${statusCondition}
       ORDER BY s.created_at DESC
       LIMIT $1 OFFSET $2`,
      params
    );

    const totalPages = Math.ceil(countResult.rows[0].total / limit);

    return res.status(200).json(buildSuccessResponse({
      stations: stationsResult.rows,
      pagination: { page, limit, total: countResult.rows[0].total, totalPages },
    }, 'Stations retrieved'));
  } catch (error) {
    console.error('Get all stations error:', error);
    return res.status(500).json(buildErrorResponse('Failed to retrieve stations.', 500));
  }
};

async function getStationById(id) {
  const stationResult = await query(
    `SELECT s.*, u.name AS created_by_name
     FROM charging_stations s
     LEFT JOIN users u ON u.id = s.created_by
     WHERE s.id = $1`,
    [id]
  );

  if (stationResult.rows.length === 0) return null;

  const station = stationResult.rows[0];

  station.chargers = (await query('SELECT * FROM charger_types WHERE station_id = $1 ORDER BY charger_type', [id])).rows;
  station.amenities = (await query('SELECT amenity FROM station_amenities WHERE station_id = $1', [id])).rows.map(a => a.amenity);
  station.images = (await query('SELECT * FROM station_images WHERE station_id = $1 ORDER BY created_at', [id])).rows;

  return station;
}

function getSpeedCategory(powerOutput) {
  if (!powerOutput) return 'SLOW';
  const kw = parseFloat(powerOutput);
  if (kw > 100) return 'ULTRA_FAST';
  if (kw >= 22) return 'FAST';
  return 'SLOW';
}
