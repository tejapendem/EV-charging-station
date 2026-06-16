import { Router } from 'express';
import { body, param } from 'express-validator';
import { validate } from '../middleware/validate.js';
import { authenticate } from '../middleware/auth.js';
import {
  addFavorite,
  getFavorites,
  removeFavorite,
  checkFavorite,
} from '../controllers/favoriteController.js';

const router = Router();

router.use(authenticate);

router.post(
  '/',
  [
    body('station_id')
      .isUUID(4)
      .withMessage('Invalid station ID'),
  ],
  validate,
  addFavorite
);

router.get('/', getFavorites);

router.get(
  '/check/:stationId',
  [
    param('stationId')
      .isUUID(4)
      .withMessage('Invalid station ID'),
  ],
  validate,
  checkFavorite
);

router.delete(
  '/:id',
  [
    param('id')
      .isUUID(4)
      .withMessage('Invalid favorite ID'),
  ],
  validate,
  removeFavorite
);

export default router;
