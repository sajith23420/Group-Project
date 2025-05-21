// src/config/__mocks__/firebaseAdmin.js

const mockAuth = {
  verifyIdToken: jest.fn().mockResolvedValue({ uid: 'test-uid', email: 'test@example.com', name: 'Test User' }),
};

const _resetFirebaseServiceMocks = (authToReset) => {
  if (authToReset && typeof authToReset.verifyIdToken.mockClear === 'function') {
    authToReset.verifyIdToken.mockClear().mockResolvedValue({ uid: 'test-uid', email: 'test@example.com', name: 'Test User' });
  }
};

module.exports = {
  mockAuth,
  _resetFirebaseServiceMocks,
};