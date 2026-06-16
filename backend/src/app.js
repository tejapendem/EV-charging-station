import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import compression from 'compression';
import morgan from 'morgan';
import path from 'path';
import { fileURLToPath } from 'url';
import dotenv from 'dotenv';
import { initializeFirebase } from './config/firebase.js';
import { globalLimiter } from './middleware/rateLimiter.js';
import { uploadErrorHandler } from './middleware/upload.js';

import authRoutes from './routes/auth.js';
import stationRoutes from './routes/stations.js';
import reviewRoutes from './routes/reviews.js';
import favoriteRoutes from './routes/favorites.js';
import reportRoutes from './routes/reports.js';
import externalChargerRoutes from './routes/externalChargers.js';

dotenv.config();

const __dirname = path.dirname(fileURLToPath(import.meta.url));

const app = express();
const PORT = process.env.PORT || 5000;

initializeFirebase();

app.use(helmet({
  crossOriginResourcePolicy: { policy: 'cross-origin' },
  contentSecurityPolicy: false,
}));

const corsOptions = {
  origin: process.env.NODE_ENV === 'production'
    ? ['https://evconnectindia.com', /\.evconnectindia\.com$/]
    : ['http://localhost:3000', 'http://localhost:5173', 'http://localhost:8081'],
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization', 'X-Requested-With'],
  exposedHeaders: ['X-Total-Count', 'X-Page', 'X-Total-Pages'],
  credentials: true,
  maxAge: 86400,
};
app.use(cors(corsOptions));

app.use(compression());
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

if (process.env.NODE_ENV !== 'test') {
  app.use(morgan('combined'));
}

app.use('/uploads', express.static(path.join(__dirname, '../uploads')));

app.use(globalLimiter);

app.get('/api/health', (req, res) => {
  res.json({
    success: true,
    message: 'EV Connect India API is running',
    timestamp: new Date().toISOString(),
    environment: process.env.NODE_ENV || 'development',
  });
});

app.get('/api/version', (req, res) => {
  res.json({
    success: true,
    data: {
      version: '1.0.0',
      name: 'EV Connect India API',
      description: 'EV Charging Station Finder Backend',
    },
  });
});

app.use('/api/auth', authRoutes);
app.use('/api/stations', stationRoutes);
app.use('/api/reviews', reviewRoutes);
app.use('/api/favorites', favoriteRoutes);
app.use('/api/reports', reportRoutes);

app.use('/api/external-chargers', externalChargerRoutes);

app.use('/api/uploads', (req, res) => {
  res.status(400).json({
    success: false,
    message: 'Please use the appropriate API endpoints for file uploads.',
  });
});

app.use(uploadErrorHandler);

app.use((req, res) => {
  res.status(404).json({
    success: false,
    message: `Route ${req.originalUrl} not found`,
  });
});

app.use((err, req, res, next) => {
  console.error('Unhandled error:', err);
  const statusCode = err.statusCode || 500;
  const message = err.statusCode ? err.message : 'An unexpected error occurred';

  if (process.env.NODE_ENV === 'production' && statusCode === 500) {
    return res.status(500).json({
      success: false,
      message: 'An unexpected error occurred',
    });
  }

  res.status(statusCode).json({
    success: false,
    message,
    ...(process.env.NODE_ENV !== 'production' && { stack: err.stack }),
  });
});

process.on('unhandledRejection', (reason, promise) => {
  console.error('Unhandled Rejection at:', promise, 'reason:', reason);
});

process.on('uncaughtException', (error) => {
  console.error('Uncaught Exception:', error);
  process.exit(1);
});

if (process.env.NODE_ENV !== 'test') {
  app.listen(PORT, () => {
    console.log(`EV Connect India API server running on port ${PORT}`);
    console.log(`Environment: ${process.env.NODE_ENV || 'development'}`);
    console.log(`Health check: http://localhost:${PORT}/api/health`);
  });
}

export default app;
