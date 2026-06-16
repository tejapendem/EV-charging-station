import { Router } from 'express';
import { query } from 'express-validator';
import { validate } from '../middleware/validate.js';
import { getExternalChargers } from '../controllers/externalChargerController.js';

const router = Router();

router.get('/', [
  query('lat')
    .isFloat({ min: -90, max: 90 })
    .withMessage('Latitude must be between -90 and 90'),
  query('lon')
    .isFloat({ min: -180, max: 180 })
    .withMessage('Longitude must be between -180 and 180'),
  query('distance')
    .optional()
    .isFloat({ min: 0.1, max: 50 })
    .withMessage('Distance must be between 0.1 and 50 km'),
  query('limit')
    .optional()
    .isInt({ min: 1, max: 30 })
    .withMessage('Limit must be between 1 and 30'),
], validate, getExternalChargers);

export default router;
