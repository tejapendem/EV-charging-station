import { validationResult } from 'express-validator';
import { buildErrorResponse } from '../utils/helpers.js';

export const validate = (req, res, next) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    const formattedErrors = errors.array().map((err) => ({
      field: err.path,
      message: err.msg,
    }));
    return res.status(400).json({
      success: false,
      message: 'Validation failed',
      errors: formattedErrors,
    });
  }
  next();
};

export const mongoIdRule = (field) => ({
  in: ['params', 'query'],
  errorMessage: `Invalid ${field}`,
  matches: { options: [/^[a-f\d]{24}$/i], errorMessage: `${field} must be a valid ID` },
});

export const uuidRule = (field, location = 'params') => ({
  in: [location],
  errorMessage: `Invalid ${field}`,
  isUUID: { options: [4], errorMessage: `${field} must be a valid UUID` },
});

export const coordinateRule = (field) => ({
  in: ['query'],
  errorMessage: `Invalid ${field}`,
  isFloat: { options: { min: -90, max: 90 }, errorMessage: `${field} must be a valid coordinate` },
});

export const paginationRules = [
  { in: ['query'], name: 'page', optional: true, isInt: { options: { min: 1 }, errorMessage: 'Page must be a positive integer' } },
  { in: ['query'], name: 'limit', optional: true, isInt: { options: { min: 1, max: 100 }, errorMessage: 'Limit must be between 1 and 100' } },
];
