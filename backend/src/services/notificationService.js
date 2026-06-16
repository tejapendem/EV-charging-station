import { getFirebaseApp } from '../config/firebase.js';
import { query } from '../config/database.js';

export const sendNotification = async (userId, title, body, data = {}) => {
  try {
    const app = getFirebaseApp();
    if (!app) {
      console.warn('Firebase not configured. Notification not sent.');
      return { success: false, message: 'Firebase not configured' };
    }

    const userResult = await query('SELECT fcm_token FROM users WHERE id = $1 AND fcm_token IS NOT NULL', [userId]);
    if (userResult.rows.length === 0) {
      console.warn(`No FCM token found for user ${userId}`);
      return { success: false, message: 'No FCM token' };
    }

    const fcmToken = userResult.rows[0].fcm_token;

    const message = {
      notification: { title, body },
      data: { ...data },
      token: fcmToken,
    };

    const response = await app.messaging().send(message);
    console.log(`Notification sent to user ${userId}:`, response);

    await query(
      `INSERT INTO notifications (user_id, title, body, data, sent_at)
       VALUES ($1, $2, $3, $4, NOW())`,
      [userId, title, body, JSON.stringify(data)]
    );

    return { success: true, messageId: response };
  } catch (error) {
    console.error(`Failed to send notification to user ${userId}:`, error.message);
    if (error.code === 'messaging/registration-token-not-registered') {
      await query('UPDATE users SET fcm_token = NULL WHERE id = $1', [userId]);
    }
    return { success: false, message: error.message };
  }
};

export const sendStationUpdateNotification = async (stationId, updateType, stationName) => {
  try {
    const favorites = await query(
      `SELECT u.id, u.fcm_token
       FROM favorites f
       JOIN users u ON u.id = f.user_id
       WHERE f.station_id = $1 AND u.fcm_token IS NOT NULL`,
      [stationId]
    );

    const titleMap = {
      status_change: 'Station Status Updated',
      new_charger: 'New Charger Added',
      price_change: 'Pricing Updated',
      review_added: 'New Review Posted',
    };

    const bodyMap = {
      status_change: `${stationName} status has been updated. Check the app for details.`,
      new_charger: `${stationName} now has a new charger type available!`,
      price_change: `${stationName} has updated its pricing.`,
      review_added: `A new review has been posted for ${stationName}.`,
    };

    const title = titleMap[updateType] || 'Station Update';
    const body = bodyMap[updateType] || `${stationName} has been updated.`;

    const results = [];
    for (const fav of favorites.rows) {
      const result = await sendNotification(fav.id, title, body, { stationId, updateType });
      results.push(result);
    }

    return { success: true, notificationsSent: results.length };
  } catch (error) {
    console.error('Station update notification error:', error.message);
    return { success: false, message: error.message };
  }
};

export const sendWelcomeNotification = async (userId, name) => {
  return sendNotification(userId, `Welcome to EV Connect India!`, `Hi ${name}, start finding EV charging stations near you.`);
};
