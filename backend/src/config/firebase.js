import admin from 'firebase-admin';
import dotenv from 'dotenv';

dotenv.config();

let firebaseApp = null;

export const initializeFirebase = () => {
  if (firebaseApp) return firebaseApp;

  const requiredVars = ['FIREBASE_PROJECT_ID', 'FIREBASE_PRIVATE_KEY', 'FIREBASE_CLIENT_EMAIL'];
  const missing = requiredVars.filter((v) => !process.env[v]);
  if (missing.length > 0) {
    console.warn(`Firebase config missing: ${missing.join(', ')}. Firebase auth will be unavailable.`);
    return null;
  }

  try {
    firebaseApp = admin.initializeApp({
      credential: admin.credential.cert({
        projectId: process.env.FIREBASE_PROJECT_ID,
        privateKey: (process.env.FIREBASE_PRIVATE_KEY || '').replace(/\\n/g, '\n'),
        clientEmail: process.env.FIREBASE_CLIENT_EMAIL,
      }),
    });
    console.log('Firebase Admin SDK initialized');
    return firebaseApp;
  } catch (error) {
    console.error('Firebase initialization error:', error.message);
    return null;
  }
};

export const verifyFirebaseToken = async (idToken) => {
  const app = initializeFirebase();
  if (!app) {
    throw new Error('Firebase is not configured');
  }
  try {
    const decodedToken = await admin.auth().verifyIdToken(idToken);
    return decodedToken;
  } catch (error) {
    throw new Error(`Firebase token verification failed: ${error.message}`);
  }
};

export const getFirebaseApp = () => {
  if (!firebaseApp) return initializeFirebase();
  return firebaseApp;
};

export default { initializeFirebase, verifyFirebaseToken, getFirebaseApp };
