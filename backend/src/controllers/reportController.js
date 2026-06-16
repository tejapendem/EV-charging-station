import { query } from '../config/database.js';
import { buildSuccessResponse, buildErrorResponse, paginate } from '../utils/helpers.js';

export const createReport = async (req, res) => {
  try {
    const { station_id, report_type, description } = req.body;
    const userId = req.user.id;

    const validTypes = ['CLOSED', 'WRONG_LOCATION', 'PRICING_ISSUE', 'CHARGER_BROKEN'];
    if (!validTypes.includes(report_type)) {
      return res.status(400).json(buildErrorResponse(
        `Invalid report type. Must be one of: ${validTypes.join(', ')}`,
        400
      ));
    }

    const stationExists = await query('SELECT id, name FROM charging_stations WHERE id = $1', [station_id]);
    if (stationExists.rows.length === 0) {
      return res.status(404).json(buildErrorResponse('Station not found.', 404));
    }

    const existingPending = await query(
      `SELECT id FROM reports WHERE user_id = $1 AND station_id = $2 AND status = 'PENDING'`,
      [userId, station_id]
    );
    if (existingPending.rows.length > 0) {
      return res.status(409).json(buildErrorResponse('You already have a pending report for this station.', 409));
    }

    const result = await query(
      `INSERT INTO reports (user_id, station_id, report_type, description)
       VALUES ($1, $2, $3, $4)
       RETURNING *`,
      [userId, station_id, report_type, description || null]
    );

    const report = result.rows[0];
    report.station_name = stationExists.rows[0].name;
    report.user_name = req.user.name;

    return res.status(201).json(buildSuccessResponse(report, 'Report submitted successfully'));
  } catch (error) {
    console.error('Create report error:', error);
    return res.status(500).json(buildErrorResponse('Failed to submit report.', 500));
  }
};

export const getReports = async (req, res) => {
  try {
    const { page: queryPage, limit: queryLimit, status: filterStatus, report_type } = req.query;
    const { page, limit } = paginate(queryPage, queryLimit);

    const conditions = [];
    const params = [];
    let paramIndex = 1;

    if (filterStatus) {
      conditions.push(`r.status = $${paramIndex}`);
      params.push(filterStatus);
      paramIndex++;
    }

    if (report_type) {
      conditions.push(`r.report_type = $${paramIndex}`);
      params.push(report_type);
      paramIndex++;
    }

    const whereClause = conditions.length > 0 ? `WHERE ${conditions.join(' AND ')}` : '';

    const countResult = await query(
      `SELECT COUNT(*)::int AS total FROM reports r ${whereClause}`,
      params
    );

    const reportsResult = await query(
      `SELECT
        r.*, u.name AS user_name, u.email AS user_email,
        s.name AS station_name, s.address AS station_address, s.city AS station_city
       FROM reports r
       JOIN users u ON u.id = r.user_id
       JOIN charging_stations s ON s.id = r.station_id
       ${whereClause}
       ORDER BY r.created_at DESC
       LIMIT $${paramIndex} OFFSET $${paramIndex + 1}`,
      [...params, limit, (page - 1) * limit]
    );

    const totalPages = Math.ceil(countResult.rows[0].total / limit);

    return res.status(200).json(buildSuccessResponse({
      reports: reportsResult.rows,
      pagination: { page, limit, total: countResult.rows[0].total, totalPages },
    }, 'Reports retrieved'));
  } catch (error) {
    console.error('Get reports error:', error);
    return res.status(500).json(buildErrorResponse('Failed to retrieve reports.', 500));
  }
};

export const updateReportStatus = async (req, res) => {
  try {
    const { id } = req.params;
    const { status, admin_notes } = req.body;

    const validStatuses = ['PENDING', 'IN_REVIEW', 'RESOLVED', 'DISMISSED'];
    if (!validStatuses.includes(status)) {
      return res.status(400).json(buildErrorResponse(
        `Invalid status. Must be one of: ${validStatuses.join(', ')}`,
        400
      ));
    }

    const report = await query('SELECT * FROM reports WHERE id = $1', [id]);
    if (report.rows.length === 0) {
      return res.status(404).json(buildErrorResponse('Report not found.', 404));
    }

    const result = await query(
      `UPDATE reports SET status = $1, admin_notes = $2, resolved_at = CASE WHEN $1 = 'RESOLVED' THEN NOW() ELSE resolved_at END, updated_at = NOW()
       WHERE id = $3
       RETURNING *`,
      [status, admin_notes || null, id]
    );

    return res.status(200).json(buildSuccessResponse(result.rows[0], 'Report status updated'));
  } catch (error) {
    console.error('Update report error:', error);
    return res.status(500).json(buildErrorResponse('Failed to update report.', 500));
  }
};

export const getUserReports = async (req, res) => {
  try {
    const userId = req.user.id;
    const { page: queryPage, limit: queryLimit } = req.query;
    const { page, limit } = paginate(queryPage, queryLimit);

    const countResult = await query(
      'SELECT COUNT(*)::int AS total FROM reports WHERE user_id = $1',
      [userId]
    );

    const reportsResult = await query(
      `SELECT r.*, s.name AS station_name, s.address AS station_address
       FROM reports r
       JOIN charging_stations s ON s.id = r.station_id
       WHERE r.user_id = $1
       ORDER BY r.created_at DESC
       LIMIT $2 OFFSET $3`,
      [userId, limit, (page - 1) * limit]
    );

    const totalPages = Math.ceil(countResult.rows[0].total / limit);

    return res.status(200).json(buildSuccessResponse({
      reports: reportsResult.rows,
      pagination: { page, limit, total: countResult.rows[0].total, totalPages },
    }, 'Reports retrieved'));
  } catch (error) {
    console.error('Get user reports error:', error);
    return res.status(500).json(buildErrorResponse('Failed to retrieve reports.', 500));
  }
};
