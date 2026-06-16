import crypto from 'crypto';

export const generateId = () => crypto.randomUUID();

export const generateToken = (length = 32) =>
  crypto.randomBytes(length).toString('hex');

export const sanitizeUser = (user) => {
  if (!user) return null;
  const { password_hash, firebase_uid, ...safeUser } = user;
  return safeUser;
};

export const sanitizeStation = (station) => {
  if (!station) return null;
  const { created_by, ...safeStation } = station;
  return safeStation;
};

export const haversineDistance = (lat1, lon1, lat2, lon2) => {
  const R = 6371;
  const dLat = toRad(lat2 - lat1);
  const dLon = toRad(lon2 - lon1);
  const a =
    Math.sin(dLat / 2) * Math.sin(dLat / 2) +
    Math.cos(toRad(lat1)) *
      Math.cos(toRad(lat2)) *
      Math.sin(dLon / 2) *
      Math.sin(dLon / 2);
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
  return R * c;
};

const toRad = (deg) => (deg * Math.PI) / 180;

export const paginate = (page = 1, limit = 20) => {
  page = Math.max(1, parseInt(page, 10) || 1);
  limit = Math.min(100, Math.max(1, parseInt(limit, 10) || 20));
  const offset = (page - 1) * limit;
  return { page, limit, offset };
};

export const buildSuccessResponse = (data, message = 'Success') => ({
  success: true,
  message,
  data,
});

export const buildErrorResponse = (message = 'An error occurred', statusCode = 500) => ({
  success: false,
  message,
  statusCode,
});
