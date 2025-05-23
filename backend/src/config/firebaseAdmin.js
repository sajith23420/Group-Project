// src/config/firebaseAdmin.js
const admin = require('firebase-admin');
const path = require('path');

// Prevent re-initialization if already initialized (e.g., by Jest setup mock)
if (!admin.apps.length) { 
  try {
    let initialized = false;
    const databaseURL = process.env.FIREBASE_DATABASE_URL;

    if (!databaseURL) {
      console.error('Firebase Admin SDK initialization error: FIREBASE_DATABASE_URL is not set in the .env file.');
    } else {
      const serviceAccountPathEnv = process.env.FIREBASE_SERVICE_ACCOUNT_PATH;

      if (serviceAccountPathEnv) {
        try {
          const absolutePath = path.resolve(serviceAccountPathEnv);
          const serviceAccount = require(absolutePath); // This can be problematic if file doesn't exist
          admin.initializeApp({
            credential: admin.credential.cert(serviceAccount),
            databaseURL: databaseURL,
          });
          console.log(`Firebase Admin SDK initialized using service account file from FIREBASE_SERVICE_ACCOUNT_PATH: ${absolutePath}`);
          initialized = true;
        } catch (e) {
          console.error(`Error loading service account from FIREBASE_SERVICE_ACCOUNT_PATH (${serviceAccountPathEnv}):`, e.message);
          if (e.code === 'MODULE_NOT_FOUND') {
            console.error(`Ensure the service account key file exists at the specified path.`);
          }
        }
      }

      if (!initialized && process.env.GOOGLE_APPLICATION_CREDENTIALS) {
        try {
          admin.initializeApp({
            credential: admin.credential.applicationDefault(),
            databaseURL: databaseURL,
          });
          console.log('Firebase Admin SDK initialized using Application Default Credentials (GOOGLE_APPLICATION_CREDENTIALS).');
          initialized = true;
        } catch (e) {
          console.error('Error initializing with GOOGLE_APPLICATION_CREDENTIALS:', e.message);
        }
      }
      
      if (!initialized && process.env.FIREBASE_SERVICE_ACCOUNT_KEY_JSON) {
        try {
          const serviceAccountKey = JSON.parse(process.env.FIREBASE_SERVICE_ACCOUNT_KEY_JSON);
          admin.initializeApp({
            credential: admin.credential.cert(serviceAccountKey),
            databaseURL: databaseURL,
          });
          console.log('Firebase Admin SDK initialized using service account JSON from FIREBASE_SERVICE_ACCOUNT_KEY_JSON.');
          initialized = true;
        } catch (e) {
          console.error('Error initializing with FIREBASE_SERVICE_ACCOUNT_KEY_JSON:', e.message);
        }
      }

      if (!initialized) {
        console.warn('Firebase Admin SDK not initialized. Ensure one of the following is correctly set: FIREBASE_SERVICE_ACCOUNT_PATH (pointing to src/config/your-key.json), GOOGLE_APPLICATION_CREDENTIALS, or FIREBASE_SERVICE_ACCOUNT_KEY_JSON.');
      }
    }
  } catch (error) {
    console.error('General Firebase Admin SDK initialization error:', error.message);
  }
} else if (process.env.NODE_ENV !== 'test') { // Log if already initialized outside of test
    console.log('Firebase Admin SDK was already initialized.');
}


module.exports = admin;