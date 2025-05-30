// __tests__/routes/userAuth.test.js

jest.mock('fs', () => ({
  ...jest.requireActual('fs'),
  writeFile: jest.fn((path, data, callback) => callback(null)),
  mkdirSync: jest.fn(),
  existsSync: jest.fn().mockReturnValue(true),
  unlinkSync: jest.fn(),
  rmSync: jest.fn(),
}));
jest.mock('uuid', () => ({
  v4: jest.fn(() => 'mock-uuid-1234')
}));

const request = require('supertest');
const app = require('../../app');
const admin = require('../../src/config/firebaseAdmin'); // REAL admin object
const fs = require('fs');
const path = require('path');
const { USER_ROLES } = require('../../src/config/constants');

const USER_PROFILE_PICTURES_DIR = path.join(__dirname, '..', '..', 'uploads', 'user_profile_pictures');

function createUserData(overrides = {}) {
  const randomSuffix = Math.random().toString(36).substring(2, 9);
  return {
    uid: overrides.uid || `test-uid-${randomSuffix}`,
    email: overrides.email || `${overrides.role || 'user'}-${randomSuffix}@example.com`,
    displayName: overrides.displayName || 'Test User ' + randomSuffix,
    phoneNumber: overrides.phoneNumber || '1234567890',
    role: overrides.role || USER_ROLES.USER,
    profilePictureUrl: overrides.profilePictureUrl || null,
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString(),
    paymentHistoryRefs: overrides.paymentHistoryRefs || [],
    ...overrides,
  };
}

describe('User Auth Routes', () => {
  let mockUser;
  let mockAdminUser;
  let mockUserToUpdate;

  const MOCK_USER_TOKEN = 'mock-token-regular-user';
  const MOCK_ADMIN_TOKEN = 'mock-token-admin-user';
  const MOCK_NONEXISTENT_TOKEN = 'mock-token-nonexistent-user';

  beforeEach(async () => {
    fs.writeFile.mockClear().mockImplementation((path, data, callback) => callback(null));
    fs.mkdirSync.mockClear();
    fs.existsSync.mockClear().mockReturnValue(true); // Default to true
    fs.unlinkSync.mockClear();

    // Directly mock the verifyIdToken method on the real admin.auth() object
    // This ensures the middleware uses this mock.
    // Ensure admin.auth() itself is available and verifyIdToken is a function before mocking
    if (!admin.auth() || typeof admin.auth().verifyIdToken !== 'function') {
        // If this happens, it means firebaseAdmin.js didn't initialize auth() correctly,
        // or it's not structured as expected. For now, we'll assume it is.
        // If it's not a Jest mock function yet, make it one.
        if (admin.auth()) { // Make sure auth() is callable
             admin.auth().verifyIdToken = jest.fn();
        } else {
            // This would be a deeper issue with firebaseAdmin setup for tests
            console.error("admin.auth() is not available or verifyIdToken is not a function. Mocking will fail.");
            // As a fallback, create a mock auth object if admin.auth is undefined
            admin.auth = jest.fn().mockReturnValue({ verifyIdToken: jest.fn() });
        }
    }
    
    admin.auth().verifyIdToken.mockImplementation(async (token) => {
      if (token === MOCK_USER_TOKEN) return { uid: mockUser.uid, email: mockUser.email, name: mockUser.displayName };
      if (token === MOCK_ADMIN_TOKEN) return { uid: mockAdminUser.uid, email: mockAdminUser.email, name: mockAdminUser.displayName };
      if (token === MOCK_NONEXISTENT_TOKEN) return { uid: 'non-existent-uid-for-test', email: 'no-db-entry@example.com', name: 'Non Existent' };
      console.error("verifyIdToken mock called with unhandled token:", token);
      // It's important that this mock throws an error similar to what the real one would for invalid tokens
      const error = new Error('Mock decoding Firebase ID token failed.');
      error.code = 'auth/argument-error'; // Simulate the error code
      throw error;
    });

    mockUser = createUserData({ uid: 'test-user-uid', role: USER_ROLES.USER, email: 'user@example.com', displayName: "Regular User" });
    mockAdminUser = createUserData({ uid: 'test-admin-uid', role: USER_ROLES.ADMIN, email: 'admin@example.com', displayName: "Admin User" });
    mockUserToUpdate = createUserData({ uid: 'user-to-be-updated-uid', role: USER_ROLES.USER, email: 'update@example.com', displayName: 'User To Update' });

    if (admin.database()) { // Ensure database is available
        await admin.database().ref('users').set(null);
        await admin.database().ref(`users/${mockUser.uid}`).set(mockUser);
        await admin.database().ref(`users/${mockAdminUser.uid}`).set(mockAdminUser);
    } else {
        console.error("admin.database() is not available in beforeEach. DB setup will fail.");
    }
  });

  // ... (rest of your tests should remain the same, but will now use the correct mock)

  describe('GET /api/auth/profile', () => {
    it('should get the user profile for an authenticated user', async () => {
      const res = await request(app)
        .get('/api/auth/profile')
        .set('Authorization', `Bearer ${MOCK_USER_TOKEN}`);

      expect(res.statusCode).toEqual(200);
      expect(res.body).toHaveProperty('uid', mockUser.uid);
      expect(admin.auth().verifyIdToken).toHaveBeenCalledWith(MOCK_USER_TOKEN);
    });

    it('should return 401 if no token is provided', async () => {
      const res = await request(app).get('/api/auth/profile');
      expect(res.statusCode).toEqual(401);
    });

    it('should return 404 if user profile not found in DB (real DB check)', async () => {
      const res = await request(app)
        .get('/api/auth/profile')
        .set('Authorization', `Bearer ${MOCK_NONEXISTENT_TOKEN}`);
      // The middleware will send 403 if token verification fails (as our mock now throws for unknown tokens)
      // However, if the token *is* verified but the user is not in DB, then 404.
      // Let's adjust the expectation. If the token 'MOCK_NONEXISTENT_TOKEN' resolves to a UID,
      // and that UID is not in the DB, fetchUserProfileAndAttach should result in 404.
      // The current error log shows "Decoding Firebase ID token failed" implying our mock might not be hit.
      expect(res.statusCode).toEqual(404);
    });
  });

  describe('PUT /api/auth/profile', () => {
    it('should update the user profile in the real DB', async () => {
      const updatedData = {
        displayName: 'Updated Real Test User',
        phoneNumber: '0987654321',
      };

      const res = await request(app)
        .put('/api/auth/profile')
        .set('Authorization', `Bearer ${MOCK_USER_TOKEN}`)
        .send(updatedData);

      expect(res.statusCode).toEqual(200);
      expect(res.body.displayName).toEqual(updatedData.displayName);

      const dbSnapshot = await admin.database().ref(`users/${mockUser.uid}`).once('value');
      expect(dbSnapshot.val().displayName).toEqual(updatedData.displayName);
    });

    it('should return 400 for invalid update data', async () => {
      const res = await request(app)
        .put('/api/auth/profile')
        .set('Authorization', `Bearer ${MOCK_USER_TOKEN}`)
        .send({ displayName: 'U' });
      expect(res.statusCode).toEqual(400);
    });
  });

  describe('POST /api/auth/profile/upload-picture', () => {
    it('should upload a profile picture and save it locally, updating real DB', async () => {
        const userUploadDirPath = path.join(USER_PROFILE_PICTURES_DIR, mockUser.uid);
        const expectedLocalFileName = 'profile_mock-uuid-1234.png';
        const expectedPublicUrl = `/uploads/user_profile_pictures/${mockUser.uid}/${expectedLocalFileName}`;

        fs.existsSync.mockImplementation(p => {
            if (p === userUploadDirPath) return false;
            if (p === USER_PROFILE_PICTURES_DIR) return true;
            if (p.includes(mockUser.uid) && p.includes(expectedLocalFileName)) return true;
            return false; 
        });

        const res = await request(app)
            .post('/api/auth/profile/upload-picture')
            .set('Authorization', `Bearer ${MOCK_USER_TOKEN}`)
            .attach('profilePicture', Buffer.from('fake image data'), 'profile.png');

        expect(res.statusCode).toEqual(200);
        expect(res.body.profilePictureUrl).toEqual(expectedPublicUrl);

        const dbSnapshot = await admin.database().ref(`users/${mockUser.uid}`).once('value');
        expect(dbSnapshot.val().profilePictureUrl).toEqual(expectedPublicUrl);
    });

    it('should delete old local profile picture if one exists', async () => {
        const oldPicFileName = 'old_profile_for_real_db.png';
        const oldPictureUrl = `/uploads/user_profile_pictures/${mockUser.uid}/${oldPicFileName}`;
        
        await admin.database().ref(`users/${mockUser.uid}`).update({ profilePictureUrl: oldPictureUrl });
        
        const oldLocalPath = path.join(USER_PROFILE_PICTURES_DIR, mockUser.uid, oldPicFileName);
        const userUploadDirPath = path.join(USER_PROFILE_PICTURES_DIR, mockUser.uid);

        fs.existsSync.mockImplementation(p => {
            if (p === oldLocalPath) return true; 
            if (p === userUploadDirPath) return true; 
            if (p === USER_PROFILE_PICTURES_DIR) return true; 
            return false;
        });

        await request(app)
            .post('/api/auth/profile/upload-picture')
            .set('Authorization', `Bearer ${MOCK_USER_TOKEN}`)
            .attach('profilePicture', Buffer.from('new fake image data'), 'new_profile.png');

        expect(fs.unlinkSync).toHaveBeenCalledWith(oldLocalPath);
    });


    it('should return 400 if no file is uploaded', async () => {
        const res = await request(app)
            .post('/api/auth/profile/upload-picture')
            .set('Authorization', `Bearer ${MOCK_USER_TOKEN}`);
        expect(res.statusCode).toEqual(400);
    });
  });

  describe('Admin Routes', () => {
    beforeEach(async () => {
        if(admin.database()) { // check if database is available
            await admin.database().ref(`users/${mockUserToUpdate.uid}`).set(mockUserToUpdate);
        }
    });

    describe('PUT /api/auth/admin/users/:userIdToUpdate/role', () => {
      it('should allow admin to update a user role in real DB', async () => {
        const res = await request(app)
          .put(`/api/auth/admin/users/${mockUserToUpdate.uid}/role`)
          .set('Authorization', `Bearer ${MOCK_ADMIN_TOKEN}`)
          .send({ role: USER_ROLES.ADMIN });

        expect(res.statusCode).toEqual(200);
        expect(res.body.role).toEqual(USER_ROLES.ADMIN);

        const dbSnapshot = await admin.database().ref(`users/${mockUserToUpdate.uid}`).once('value');
        expect(dbSnapshot.val().role).toEqual(USER_ROLES.ADMIN);
      });

      it('should return 403 if a non-admin tries to update role', async () => {
        const res = await request(app)
          .put(`/api/auth/admin/users/${mockUserToUpdate.uid}/role`)
          .set('Authorization', `Bearer ${MOCK_USER_TOKEN}`)
          .send({ role: USER_ROLES.ADMIN });
        expect(res.statusCode).toEqual(403);
      });

      it('should return 404 if user to update is not found in real DB', async () => {
        const res = await request(app)
          .put(`/api/auth/admin/users/truly-nonexistent-admin-target/role`)
          .set('Authorization', `Bearer ${MOCK_ADMIN_TOKEN}`)
          .send({ role: USER_ROLES.ADMIN });
        expect(res.statusCode).toEqual(404);
      });
    });

    describe('GET /api/auth/admin/users', () => {
      it('should allow admin to get all users from real DB', async () => {
        const res = await request(app)
          .get('/api/auth/admin/users')
          .set('Authorization', `Bearer ${MOCK_ADMIN_TOKEN}`);

        expect(res.statusCode).toEqual(200);
        expect(Array.isArray(res.body)).toBe(true);
        expect(res.body.length).toBeGreaterThanOrEqual(2); 
      });

      it('should return 403 if a non-admin tries to get all users', async () => {
        const res = await request(app)
          .get('/api/auth/admin/users')
          .set('Authorization', `Bearer ${MOCK_USER_TOKEN}`);
        expect(res.statusCode).toEqual(403);
      });
    });
  });

  describe('onUserCreate function (conceptual test using real DB)', () => {
    it('should create a user profile in real DB when a new Firebase Auth user is created', async () => {
      const { onUserCreate } = require('../../src/controllers/userAuthController');
      const mockUserRecord = {
        uid: 'new-auth-uid-real-db',
        email: 'newauth-real@example.com',
        displayName: 'New Auth User Real DB',
        photoURL: 'http://example.com/newphotoreal.jpg'
      };
      if(admin.database()){
        await admin.database().ref(`users/${mockUserRecord.uid}`).set(null);
      }


      const createdProfile = await onUserCreate(mockUserRecord);

      expect(createdProfile.uid).toEqual(mockUserRecord.uid);
      const dbSnapshot = await admin.database().ref(`users/${mockUserRecord.uid}`).once('value');
      expect(dbSnapshot.exists()).toBe(true);
      expect(dbSnapshot.val().email).toEqual(mockUserRecord.email);
    });
  });
});