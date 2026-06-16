import { query } from '../config/database.js';
import { buildSuccessResponse, buildErrorResponse, paginate } from '../utils/helpers.js';

export const addFavorite = async (req, res) => {
  try {
    const { station_id } = req.body;
    const userId = req.user.id;

    const stationExists = await query('SELECT id FROM charging_stations WHERE id = $1', [station_id]);
    if (stationExists.rows.length === 0) {
      return res.status(404).json(buildErrorResponse('Station not found.', 404));
    }

    const existing = await query(
      'SELECT id FROM favorites WHERE user_id = $1 AND station_id = $2',
      [userId, station_id]
    );
    if (existing.rows.length > 0) {
      return res.status(409).json(buildErrorResponse('Station is already in your favorites.', 409));
    }

    const result = await query(
      `INSERT INTO favorites (user_id, station_id)
       VALUES ($1, $2)
       RETURNING *`,
      [userId, station_id]
    );

    return res.status(201).json(buildSuccessResponse(result.rows[0], 'Station added to favorites'));
  } catch (error) {
    console.error('Add favorite error:', error);
    return res.status(500).json(buildErrorResponse('Failed to add favorite.', 500));
  }
};

export const getFavorites = async (req, res) => {
  try {
    const userId = req.user.id;
    const { page: queryPage, limit: queryLimit } = req.query;
    const { page, limit } = paginate(queryPage, queryLimit);

    const countResult = await query(
      'SELECT COUNT(*)::int AS total FROM favorites WHERE user_id = $1',
      [userId]
    );

    const favoritesResult = await query(
      `SELECT
        f.id AS favorite_id,
        f.created_at AS favorited_at,
        s.id, s.name, s.address, s.city, s.state, s.pincode,
        s.latitude, s.longitude, s.phone, s.operating_hours,
        s.price_per_kwh, s.status, s.image_url, s.is_verified
       FROM favorites f
       JOIN charging_stations s ON s.id = f.station_id
       WHERE f.user_id = $1
       ORDER BY f.created_at DESC
       LIMIT $2 OFFSET $3`,
      [userId, limit, (page - 1) * limit]
    );

    const favorites = await Promise.all(favoritesResult.rows.map(async (fav) => {
      const chargers = await query('SELECT * FROM charger_types WHERE station_id = $1', [fav.id]);
      const amenities = await query('SELECT amenity FROM station_amenities WHERE station_id = $1', [fav.id]);
      const avgRating = await query(
        'SELECT COALESCE(ROUND(AVG(rating), 1), 0)::float AS avg_rating, COUNT(*)::int AS total_reviews FROM reviews WHERE station_id = $1 AND is_verified = true',
        [fav.id]
      );
      return { ...fav, chargers: chargers.rows, amenities: amenities.rows.map(a => a.amenity), ...avgRating.rows[0] };
    }));

    const totalPages = Math.ceil(countResult.rows[0].total / limit);

    return res.status(200).json(buildSuccessResponse({
      favorites,
      pagination: { page, limit, total: countResult.rows[0].total, totalPages },
    }, 'Favorites retrieved'));
  } catch (error) {
    console.error('Get favorites error:', error);
    return res.status(500).json(buildErrorResponse('Failed to retrieve favorites.', 500));
  }
};

export const removeFavorite = async (req, res) => {
  try {
    const { id } = req.params;

    const favorite = await query('SELECT * FROM favorites WHERE id = $1', [id]);
    if (favorite.rows.length === 0) {
      return res.status(404).json(buildErrorResponse('Favorite not found.', 404));
    }

    if (favorite.rows[0].user_id !== req.user.id) {
      return res.status(403).json(buildErrorResponse('You can only remove your own favorites.', 403));
    }

    await query('DELETE FROM favorites WHERE id = $1', [id]);

    return res.status(200).json(buildSuccessResponse(null, 'Favorite removed successfully'));
  } catch (error) {
    console.error('Remove favorite error:', error);
    return res.status(500).json(buildErrorResponse('Failed to remove favorite.', 500));
  }
};

export const checkFavorite = async (req, res) => {
  try {
    const { stationId } = req.params;
    const userId = req.user.id;

    const result = await query(
      'SELECT id FROM favorites WHERE user_id = $1 AND station_id = $2',
      [userId, stationId]
    );

    return res.status(200).json(buildSuccessResponse({
      is_favorite: result.rows.length > 0,
      favorite_id: result.rows[0]?.id || null,
    }, 'Favorite status checked'));
  } catch (error) {
    console.error('Check favorite error:', error);
    return res.status(500).json(buildErrorResponse('Failed to check favorite status.', 500));
  }
};
