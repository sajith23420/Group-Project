// jest.setup.js
require('dotenv').config({ path: '.env.test' });

const admin = require('./src/config/firebaseAdmin');
const fs = require('fs');
const path = require('path');

let firebaseAppInitialized = false;

beforeAll(async () => {
  if (admin.apps.length > 0 && admin.apps[0]) {
    firebaseAppInitialized = true;
    console.log(`Firebase Admin SDK app '${admin.apps[0].name}' found for testing.`);
  } else {
    console.warn('Firebase default app not found after initial require. DB operations might fail.');
  }

  if (firebaseAppInitialized && process.env.NODE_ENV === 'test' && process.env.FIREBASE_DATABASE_URL && process.env.FIREBASE_DATABASE_URL.includes('test')) {
    try {
      console.log(`Attempting to clear test database: ${process.env.FIREBASE_DATABASE_URL}`);
      await admin.database().ref('/').set(null);
      console.log('Test database cleared before all tests.');
    } catch (e) {
      console.error('Failed to clear test database in beforeAll:', e);
    }
  } else {
    console.warn('Skipping database clear in beforeAll: App not initialized, not in test ENV, or DB URL not a test URL.');
  }
});

beforeEach(async () => {
  if (admin.auth() && typeof admin.auth().verifyIdToken.mockClear === 'function') {
    admin.auth().verifyIdToken.mockClear();
  } else if (admin.auth()) {
    admin.auth().verifyIdToken = jest.fn();
  }
});

afterAll(async () => {
  if (firebaseAppInitialized && process.env.NODE_ENV === 'test' && process.env.FIREBASE_DATABASE_URL && process.env.FIREBASE_DATABASE_URL.includes('test')) {
    try {
      console.log(`Attempting to clear test database after all tests: ${process.env.FIREBASE_DATABASE_URL}`);
      await admin.database().ref('/').set(null);
      console.log('Test database cleared after all tests.');
    } catch (e) {
      console.error('Failed to clear test database in afterAll:', e);
    }
  }

  if (firebaseAppInitialized && admin.apps.length > 0 && admin.apps[0]) {
    const appToDelete = admin.apps[0]; // Get a reference to the app
    const appNameToDelete = appToDelete.name; // Store its name before deleting
    try {
      await appToDelete.delete();
      console.log(`Firebase app '${appNameToDelete}' deleted in afterAll.`);
      firebaseAppInitialized = false; 
    } catch (e) {
      console.error(`Error deleting Firebase app '${appNameToDelete}' in afterAll:`, e.message);
    }
  } else {
    console.warn('Skipping Firebase app deletion in afterAll: App not initialized or already cleaned up.');
  }
});