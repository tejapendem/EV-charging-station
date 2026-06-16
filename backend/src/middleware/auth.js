import jwt from 'jsonwebtoken';
import { verifyFirebaseToken } from '../config/firebase.js';
import { query } from '../config/database.js';
import { buildErrorResponse } from '../utils/helpers.js';

export const authenticate = async (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json(buildErrorResponse('Access denied. No token provided.', 401));
    }

    const token = authHeader.split(' ')[1];

    let decoded;
    try {
      decoded = jwt.verify(token, process.env.JWT_SECRET);
    } catch (jwtError) {
      if (jwtError.name === 'TokenExpiredError') {
        return res.status(401).json(buildErrorResponse('Token has expired.', 401));
      }
      return res.status(401).json(buildErrorResponse('Invalid token.', 401));
    }

    const result = await query('SELECT id, name, email, role, phone, avatar_url, is_verified, created_at FROM users WHERE id = $1', [decoded.userId]);
    if (result.rows.length === 0) {
      return res.status(401).json(buildErrorResponse('User not found.', 401));
    }

    req.user = result.rows[0];
    next();
  } catch (error) {
    console.error('Authentication error:', error);
    return res.status(500).json(buildErrorResponse('Authentication failed.', 500));
  }
};

export const authenticateFirebase = async (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json(buildErrorResponse('Access denied. No token provided.', 401));
    }

    const idToken = authHeader.split(' ')[1];

    const firebaseUser = await verifyFirebaseToken(idToken);

    const result = await query(
      'SELECT id, name, email, role, phone, avatar_url, is_verified, created_at FROM users WHERE firebase_uid = $1',
      [firebaseUser.uid]
    );

    if (result.rows.length === 0) {
      const newUser = await query(
        `INSERT INTO users (firebase_uid, email, name, avatar_url, auth_provider)
         VALUES ($1, $2, $3, $4, 'google')
         RETURNING id, name, email, role, phone, avatar_url, is_verified, created_at`,
        [firebaseUser.uid, firebaseUser.email || '', firebaseUser.name || firebaseUser.email?.split('@')[0] || 'User', firebaseUser.picture || '']
      );
      req.user = newUser.rows[0];
      return next();
    }

    req.user = result.rows[0];
    next();
  } catch (error) {
    console.error('Firebase authentication error:', error);
    return res.status(401).json(buildErrorResponse('Firebase authentication failed.', 401));
  }
};

export const optionalAuth = async (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      req.user = null;
      return next();
    }

    const token = authHeader.split(' ')[1];
    try {
      const decoded = jwt.verify(token, process.env.JWT_SECRET);
      const result = await query('SELECT id, name, email, role FROM users WHERE id = $1', [decoded.userId]);
      req.user = result.rows.length > 0 ? result.rows[0] : null;
    } catch {
      req.user = null;
    }
    next();
  } catch (error) {
    req.user = null;
    next();
  }
};

export const requireAdmin = (req, res, next) => {
  if (!req.user) {
    return res.status(401).json(buildErrorResponse('Authentication required.', 401));
  }
  if (req.user.role !== 'admin') {
    return res.status(403).json(buildErrorResponse('Admin access required.', 403));
  }
  next();
};

export const requireOwnershipOrAdmin = (getOwnerId) => (req, res, next) => {
  if (!req.user) {
    return res.status(401).json(buildErrorResponse('Authentication required.', 401));
  }
  if (req.user.role === 'admin') return next();

  const ownerId = getOwnerId(req);
  if (req.user.id !== ownerId) {
    return res.status(403).json(buildErrorResponse('You do not have permission to perform this action.', 403));
  }
  next();
};
