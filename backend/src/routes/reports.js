import { Router } from 'express';
import { body, param } from 'express-validator';
import { validate } from '../middleware/validate.js';
import { authenticate, requireAdmin } from '../middleware/auth.js';
import {
  createReport,
  getReports,
  updateReportStatus,
  getUserReports,
} from '../controllers/reportController.js';

const router = Router();

const validReportTypes = ['CLOSED', 'WRONG_LOCATION', 'PRICING_ISSUE', 'CHARGER_BROKEN'];
const validReportStatuses = ['PENDING', 'IN_REVIEW', 'RESOLVED', 'DISMISSED'];

router.post(
  '/',
  authenticate,
  [
    body('station_id')
      .isUUID(4)
      .withMessage('Invalid station ID'),
    body('report_type')
      .isIn(validReportTypes)
      .withMessage(`Report type must be one of: ${validReportTypes.join(', ')}`),
    body('description')
      .optional()
      .trim()
      .isLength({ min: 10, max: 2000 })
      .withMessage('Description must be between 10 and 2000 characters'),
  ],
  validate,
  createReport
);

router.get('/my-reports', authenticate, getUserReports);

router.get(
  '/',
  authenticate,
  requireAdmin,
  getReports
);

router.put(
  '/:id',
  authenticate,
  requireAdmin,
  [
    param('id')
      .isUUID(4)
      .withMessage('Invalid report ID'),
    body('status')
      .isIn(validReportStatuses)
      .withMessage(`Status must be one of: ${validReportStatuses.join(', ')}`),
    body('admin_notes')
      .optional()
      .trim()
      .isLength({ max: 2000 })
      .withMessage('Admin notes must not exceed 2000 characters'),
  ],
  validate,
  updateReportStatus
);

export default router;
