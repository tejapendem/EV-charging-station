import { Router } from 'express';
import { body, query, param } from 'express-validator';
import { validate } from '../middleware/validate.js';
import { authenticate, requireAdmin, optionalAuth } from '../middleware/auth.js';
import { stationCreationLimiter } from '../middleware/rateLimiter.js';
import { upload } from '../middleware/upload.js';
import {
  createStation,
  getStation,
  updateStation,
  deleteStation,
  getNearbyStations,
  searchStations,
  getStationChargers,
  getAllStations,
} from '../controllers/stationController.js';

const router = Router();

const validChargerTypes = ['CCS2', 'Type2', 'CHAdeMO', 'Bharat_DC001', 'Bharat_AC001'];
const validStatus = ['ACTIVE', 'INACTIVE', 'UNDER_MAINTENANCE'];
const validAmenities = ['RESTROOMS', 'FOOD_COURT', 'HOTEL', 'WIFI', 'PARKING'];

router.get('/nearby', [
  query('lat')
    .isFloat({ min: -90, max: 90 })
    .withMessage('Latitude must be between -90 and 90'),
  query('lng')
    .isFloat({ min: -180, max: 180 })
    .withMessage('Longitude must be between -180 and 180'),
  query('radius')
    .optional()
    .isFloat({ min: 0.1, max: 500 })
    .withMessage('Radius must be between 0.1 and 500 km'),
  query('page')
    .optional()
    .isInt({ min: 1 })
    .withMessage('Page must be a positive integer'),
  query('limit')
    .optional()
    .isInt({ min: 1, max: 100 })
    .withMessage('Limit must be between 1 and 100'),
], validate, getNearbyStations);

router.get('/search', [
  query('q')
    .optional()
    .trim()
    .isLength({ min: 2 })
    .withMessage('Search query must be at least 2 characters'),
  query('city')
    .optional()
    .trim(),
  query('state')
    .optional()
    .trim(),
  query('charger_type')
    .optional()
    .isIn(validChargerTypes)
    .withMessage(`Charger type must be one of: ${validChargerTypes.join(', ')}`),
  query('status')
    .optional()
    .isIn(validStatus)
    .withMessage(`Status must be one of: ${validStatus.join(', ')}`),
], validate, searchStations);

router.get('/', [
  query('page')
    .optional()
    .isInt({ min: 1 })
    .withMessage('Page must be a positive integer'),
  query('limit')
    .optional()
    .isInt({ min: 1, max: 100 })
    .withMessage('Limit must be between 1 and 100'),
  query('status')
    .optional()
    .isIn(validStatus)
    .withMessage(`Status must be one of: ${validStatus.join(', ')}`),
], validate, getAllStations);

router.get('/:id', [
  param('id').isUUID(4).withMessage('Invalid station ID'),
], validate, getStation);

router.get('/:id/chargers', [
  param('id').isUUID(4).withMessage('Invalid station ID'),
], validate, getStationChargers);

router.post(
  '/',
  authenticate,
  stationCreationLimiter,
  upload.single('image'),
  [
    body('name')
      .trim()
      .isLength({ min: 2, max: 200 })
      .withMessage('Station name must be between 2 and 200 characters'),
    body('address')
      .trim()
      .isLength({ min: 5, max: 500 })
      .withMessage('Address must be between 5 and 500 characters'),
    body('city')
      .trim()
      .isLength({ min: 2, max: 100 })
      .withMessage('City must be between 2 and 100 characters'),
    body('state')
      .trim()
      .isLength({ min: 2, max: 100 })
      .withMessage('State must be between 2 and 100 characters'),
    body('pincode')
      .optional({ values: 'falsy' })
      .matches(/^\d{6}$/)
      .withMessage('Pincode must be a 6-digit number'),
    body('latitude')
      .optional()
      .isFloat({ min: -90, max: 90 })
      .withMessage('Latitude must be between -90 and 90'),
    body('longitude')
      .optional()
      .isFloat({ min: -180, max: 180 })
      .withMessage('Longitude must be between -180 and 180'),
    body('phone')
      .optional({ values: 'falsy' })
      .matches(/^\+?[\d\s-]{10,15}$/)
      .withMessage('Please provide a valid phone number'),
    body('status')
      .optional()
      .isIn(validStatus)
      .withMessage(`Status must be one of: ${validStatus.join(', ')}`),
    body('chargers.*.charger_type')
      .optional()
      .isIn(validChargerTypes)
      .withMessage(`Charger type must be one of: ${validChargerTypes.join(', ')}`),
    body('amenities.*')
      .optional()
      .isIn(validAmenities)
      .withMessage(`Amenity must be one of: ${validAmenities.join(', ')}`),
  ],
  validate,
  createStation
);

router.put(
  '/:id',
  authenticate,
  requireAdmin,
  upload.single('image'),
  [
    param('id').isUUID(4).withMessage('Invalid station ID'),
    body('status')
      .optional()
      .isIn(validStatus)
      .withMessage(`Status must be one of: ${validStatus.join(', ')}`),
  ],
  validate,
  updateStation
);

router.delete(
  '/:id',
  authenticate,
  requireAdmin,
  [
    param('id').isUUID(4).withMessage('Invalid station ID'),
  ],
  validate,
  deleteStation
);

export default router;
