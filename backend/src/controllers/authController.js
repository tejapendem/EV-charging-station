import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import { query } from '../config/database.js';
import { verifyFirebaseToken } from '../config/firebase.js';
import { sanitizeUser, buildSuccessResponse, buildErrorResponse } from '../utils/helpers.js';
import { sendWelcomeNotification } from '../services/notificationService.js';

const generateToken = (userId) => {
  return jwt.sign({ userId }, process.env.JWT_SECRET, {
    expiresIn: process.env.JWT_EXPIRES_IN || '7d',
  });
};

export const register = async (req, res) => {
  try {
    const { name, email, phone, password } = req.body;

    const existingUser = await query('SELECT id FROM users WHERE email = $1', [email.toLowerCase()]);
    if (existingUser.rows.length > 0) {
      return res.status(409).json(buildErrorResponse('An account with this email already exists.', 409));
    }

    const salt = await bcrypt.genSalt(12);
    const passwordHash = await bcrypt.hash(password, salt);

    const result = await query(
      `INSERT INTO users (name, email, phone, password_hash, auth_provider, is_verified)
       VALUES ($1, $2, $3, $4, 'email', true)
       RETURNING id, name, email, role, phone, avatar_url, is_verified, created_at`,
      [name, email.toLowerCase(), phone || null, passwordHash]
    );

    const user = result.rows[0];
    const token = generateToken(user.id);

    await sendWelcomeNotification(user.id, user.name).catch(() => {});

    return res.status(201).json(buildSuccessResponse({
      user: sanitizeUser(user),
      token,
    }, 'Registration successful'));
  } catch (error) {
    console.error('Registration error:', error);
    return res.status(500).json(buildErrorResponse('Registration failed. Please try again.', 500));
  }
};

export const login = async (req, res) => {
  try {
    const { email, password } = req.body;

    const result = await query('SELECT * FROM users WHERE email = $1', [email.toLowerCase()]);
    if (result.rows.length === 0) {
      return res.status(401).json(buildErrorResponse('Invalid email or password.', 401));
    }

    const user = result.rows[0];

    if (!user.password_hash) {
      return res.status(401).json(buildErrorResponse('This account uses Google login. Please sign in with Google.', 401));
    }

    const isPasswordValid = await bcrypt.compare(password, user.password_hash);
    if (!isPasswordValid) {
      return res.status(401).json(buildErrorResponse('Invalid email or password.', 401));
    }

    const token = generateToken(user.id);

    return res.status(200).json(buildSuccessResponse({
      user: sanitizeUser(user),
      token,
    }, 'Login successful'));
  } catch (error) {
    console.error('Login error:', error);
    return res.status(500).json(buildErrorResponse('Login failed. Please try again.', 500));
  }
};

export const googleAuth = async (req, res) => {
  try {
    const { idToken } = req.body;

    if (!idToken) {
      return res.status(400).json(buildErrorResponse('ID token is required.', 400));
    }

    const firebaseUser = await verifyFirebaseToken(idToken);

    const result = await query('SELECT * FROM users WHERE firebase_uid = $1', [firebaseUser.uid]);

    let user;
    if (result.rows.length > 0) {
      user = result.rows[0];
      if (firebaseUser.name || firebaseUser.picture) {
        await query(
          'UPDATE users SET name = COALESCE(NULLIF($1, \'\'), name), avatar_url = COALESCE(NULLIF($2, \'\'), avatar_url), last_login = NOW() WHERE id = $3',
          [firebaseUser.name || '', firebaseUser.picture || '', user.id]
        );
      }
      user.name = firebaseUser.name || user.name;
      user.avatar_url = firebaseUser.picture || user.avatar_url;
    } else {
      const newUser = await query(
        `INSERT INTO users (firebase_uid, email, name, avatar_url, auth_provider, is_verified)
         VALUES ($1, $2, $3, $4, 'google', true)
         RETURNING *`,
        [firebaseUser.uid, firebaseUser.email || '', firebaseUser.name || firebaseUser.email?.split('@')[0] || 'User', firebaseUser.picture || '']
      );
      user = newUser.rows[0];
      await sendWelcomeNotification(user.id, user.name).catch(() => {});
    }

    const token = generateToken(user.id);

    return res.status(200).json(buildSuccessResponse({
      user: sanitizeUser(user),
      token,
    }, 'Google authentication successful'));
  } catch (error) {
    console.error('Google auth error:', error);
    return res.status(401).json(buildErrorResponse('Google authentication failed.', 401));
  }
};

export const getProfile = async (req, res) => {
  try {
    return res.status(200).json(buildSuccessResponse({ user: req.user }, 'Profile retrieved'));
  } catch (error) {
    return res.status(500).json(buildErrorResponse('Failed to retrieve profile.', 500));
  }
};

export const updateProfile = async (req, res) => {
  try {
    const { name, phone } = req.body;
    const userId = req.user.id;

    const result = await query(
      `UPDATE users SET
        name = COALESCE(NULLIF($1, ''), name),
        phone = COALESCE(NULLIF($2, ''), phone),
        updated_at = NOW()
       WHERE id = $3
       RETURNING id, name, email, role, phone, avatar_url, is_verified, created_at`,
      [name, phone, userId]
    );

    return res.status(200).json(buildSuccessResponse({ user: result.rows[0] }, 'Profile updated'));
  } catch (error) {
    console.error('Update profile error:', error);
    return res.status(500).json(buildErrorResponse('Failed to update profile.', 500));
  }
};

export const updateFcmToken = async (req, res) => {
  try {
    const { fcmToken } = req.body;
    await query('UPDATE users SET fcm_token = $1 WHERE id = $2', [fcmToken, req.user.id]);
    return res.status(200).json(buildSuccessResponse(null, 'FCM token updated'));
  } catch (error) {
    return res.status(500).json(buildErrorResponse('Failed to update FCM token.', 500));
  }
};
