import { query } from '../config/database.js';
import { buildSuccessResponse, buildErrorResponse, paginate } from '../utils/helpers.js';
import { sendStationUpdateNotification } from '../services/notificationService.js';

export const createReview = async (req, res) => {
  try {
    const { station_id, rating, comment } = req.body;
    const userId = req.user.id;

    const stationExists = await query('SELECT id, name FROM charging_stations WHERE id = $1', [station_id]);
    if (stationExists.rows.length === 0) {
      return res.status(404).json(buildErrorResponse('Station not found.', 404));
    }

    const existingReview = await query(
      'SELECT id FROM reviews WHERE user_id = $1 AND station_id = $2',
      [userId, station_id]
    );
    if (existingReview.rows.length > 0) {
      return res.status(409).json(buildErrorResponse('You have already reviewed this station.', 409));
    }

    const result = await query(
      `INSERT INTO reviews (user_id, station_id, rating, comment, is_verified)
       VALUES ($1, $2, $3, $4, true)
       RETURNING *`,
      [userId, station_id, rating, comment || null]
    );

    const review = result.rows[0];
    review.user = req.user;

    await sendStationUpdateNotification(station_id, 'review_added', stationExists.rows[0].name).catch(() => {});

    return res.status(201).json(buildSuccessResponse(review, 'Review created successfully'));
  } catch (error) {
    console.error('Create review error:', error);
    return res.status(500).json(buildErrorResponse('Failed to create review.', 500));
  }
};

export const getStationReviews = async (req, res) => {
  try {
    const { stationId } = req.params;
    const { page: queryPage, limit: queryLimit } = req.query;
    const { page, limit } = paginate(queryPage, queryLimit);

    const stationExists = await query('SELECT id FROM charging_stations WHERE id = $1', [stationId]);
    if (stationExists.rows.length === 0) {
      return res.status(404).json(buildErrorResponse('Station not found.', 404));
    }

    const countResult = await query(
      'SELECT COUNT(*)::int AS total FROM reviews WHERE station_id = $1 AND is_verified = true',
      [stationId]
    );

    const reviewsResult = await query(
      `SELECT r.*, u.name AS user_name, u.avatar_url AS user_avatar
       FROM reviews r
       JOIN users u ON u.id = r.user_id
       WHERE r.station_id = $1 AND r.is_verified = true
       ORDER BY r.created_at DESC
       LIMIT $2 OFFSET $3`,
      [stationId, limit, (page - 1) * limit]
    );

    const summary = await query(
      `SELECT
        COUNT(*)::int AS total_reviews,
        COALESCE(ROUND(AVG(rating), 1), 0)::float AS average_rating,
        COUNT(*) FILTER (WHERE rating = 5)::int AS five_star,
        COUNT(*) FILTER (WHERE rating = 4)::int AS four_star,
        COUNT(*) FILTER (WHERE rating = 3)::int AS three_star,
        COUNT(*) FILTER (WHERE rating = 2)::int AS two_star,
        COUNT(*) FILTER (WHERE rating = 1)::int AS one_star
       FROM reviews WHERE station_id = $1 AND is_verified = true`,
      [stationId]
    );

    const totalPages = Math.ceil(countResult.rows[0].total / limit);

    return res.status(200).json(buildSuccessResponse({
      reviews: reviewsResult.rows,
      summary: summary.rows[0],
      pagination: { page, limit, total: countResult.rows[0].total, totalPages },
    }, 'Reviews retrieved'));
  } catch (error) {
    console.error('Get reviews error:', error);
    return res.status(500).json(buildErrorResponse('Failed to retrieve reviews.', 500));
  }
};

export const deleteReview = async (req, res) => {
  try {
    const { id } = req.params;

    const review = await query('SELECT * FROM reviews WHERE id = $1', [id]);
    if (review.rows.length === 0) {
      return res.status(404).json(buildErrorResponse('Review not found.', 404));
    }

    if (req.user.role !== 'admin' && review.rows[0].user_id !== req.user.id) {
      return res.status(403).json(buildErrorResponse('You can only delete your own reviews.', 403));
    }

    await query('DELETE FROM reviews WHERE id = $1', [id]);

    return res.status(200).json(buildSuccessResponse(null, 'Review deleted successfully'));
  } catch (error) {
    console.error('Delete review error:', error);
    return res.status(500).json(buildErrorResponse('Failed to delete review.', 500));
  }
};

export const getUserReviews = async (req, res) => {
  try {
    const userId = req.user.id;
    const { page: queryPage, limit: queryLimit } = req.query;
    const { page, limit } = paginate(queryPage, queryLimit);

    const countResult = await query(
      'SELECT COUNT(*)::int AS total FROM reviews WHERE user_id = $1',
      [userId]
    );

    const reviewsResult = await query(
      `SELECT r.*, s.name AS station_name, s.address AS station_address,
              s.city AS station_city, s.image_url AS station_image
       FROM reviews r
       JOIN charging_stations s ON s.id = r.station_id
       WHERE r.user_id = $1
       ORDER BY r.created_at DESC
       LIMIT $2 OFFSET $3`,
      [userId, limit, (page - 1) * limit]
    );

    const totalPages = Math.ceil(countResult.rows[0].total / limit);

    return res.status(200).json(buildSuccessResponse({
      reviews: reviewsResult.rows,
      pagination: { page, limit, total: countResult.rows[0].total, totalPages },
    }, 'Reviews retrieved'));
  } catch (error) {
    console.error('Get user reviews error:', error);
    return res.status(500).json(buildErrorResponse('Failed to retrieve reviews.', 500));
  }
};
