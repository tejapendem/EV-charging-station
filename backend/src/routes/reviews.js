import { Router } from 'express';
import { body, param } from 'express-validator';
import { validate } from '../middleware/validate.js';
import { authenticate } from '../middleware/auth.js';
import {
  createReview,
  getStationReviews,
  deleteReview,
  getUserReviews,
} from '../controllers/reviewController.js';

const router = Router();

router.post(
  '/',
  authenticate,
  [
    body('station_id')
      .isUUID(4)
      .withMessage('Invalid station ID'),
    body('rating')
      .isInt({ min: 1, max: 5 })
      .withMessage('Rating must be between 1 and 5'),
    body('comment')
      .optional()
      .trim()
      .isLength({ min: 10, max: 1000 })
      .withMessage('Comment must be between 10 and 1000 characters'),
  ],
  validate,
  createReview
);

router.get('/my-reviews', authenticate, getUserReviews);

router.get(
  '/:stationId',
  [
    param('stationId')
      .isUUID(4)
      .withMessage('Invalid station ID'),
  ],
  validate,
  getStationReviews
);

router.delete(
  '/:id',
  authenticate,
  [
    param('id')
      .isUUID(4)
      .withMessage('Invalid review ID'),
  ],
  validate,
  deleteReview
);

export default router;
