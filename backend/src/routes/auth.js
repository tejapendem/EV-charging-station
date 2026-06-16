import { Router } from 'express';
import { body } from 'express-validator';
import { validate } from '../middleware/validate.js';
import { authenticate } from '../middleware/auth.js';
import { authLimiter } from '../middleware/rateLimiter.js';
import {
  register,
  login,
  googleAuth,
  getProfile,
  updateProfile,
  updateFcmToken,
} from '../controllers/authController.js';

const router = Router();

router.post(
  '/register',
  authLimiter,
  [
    body('name')
      .trim()
      .isLength({ min: 2, max: 100 })
      .withMessage('Name must be between 2 and 100 characters'),
    body('email')
      .trim()
      .isEmail()
      .normalizeEmail()
      .withMessage('Please provide a valid email address'),
    body('phone')
      .optional({ values: 'falsy' })
      .matches(/^\+?[\d\s-]{10,15}$/)
      .withMessage('Please provide a valid phone number'),
    body('password')
      .isLength({ min: 8, max: 128 })
      .withMessage('Password must be between 8 and 128 characters')
      .matches(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)/)
      .withMessage('Password must contain at least one uppercase letter, one lowercase letter, and one number'),
  ],
  validate,
  register
);

router.post(
  '/login',
  authLimiter,
  [
    body('email').trim().isEmail().normalizeEmail().withMessage('Please provide a valid email address'),
    body('password').notEmpty().withMessage('Password is required'),
  ],
  validate,
  login
);

router.post(
  '/google',
  authLimiter,
  [
    body('idToken')
      .notEmpty()
      .withMessage('Google ID token is required'),
  ],
  validate,
  googleAuth
);

router.get('/profile', authenticate, getProfile);

router.put(
  '/profile',
  authenticate,
  [
    body('name')
      .optional()
      .trim()
      .isLength({ min: 2, max: 100 })
      .withMessage('Name must be between 2 and 100 characters'),
    body('phone')
      .optional({ values: 'falsy' })
      .matches(/^\+?[\d\s-]{10,15}$/)
      .withMessage('Please provide a valid phone number'),
  ],
  validate,
  updateProfile
);

router.put(
  '/fcm-token',
  authenticate,
  [
    body('fcmToken')
      .notEmpty()
      .withMessage('FCM token is required'),
  ],
  validate,
  updateFcmToken
);

export default router;
