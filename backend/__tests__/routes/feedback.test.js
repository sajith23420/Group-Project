// __tests__/routes/feedback.test.js

const request = require('supertest');
const app = require('../../app');
const admin = require('../../src/config/firebaseAdmin'); // REAL admin object
const { USER_ROLES, FEEDBACK_STATUS } = require('../../src/config/constants');

// Helper to create feedback input data
function createFeedbackInputData(overrides = {}) {
  const randomSuffix = Math.random().toString(36).substring(2, 7);
  return {
    subject: `Feedback Subject ${randomSuffix}`,
    message: `This is a test feedback message, which is reasonably long to pass validation. ${randomSuffix}`,
    postOfficeId: overrides.postOfficeId || `po-id-feedback-${randomSuffix}`, // Optional, ensure it's a valid ID if testing PO specific feedback
    rating: Math.floor(1 + Math.random() * 5), // 1 to 5
    ...overrides,
  };
}

// Helper to create a sample Post Office for feedback association (optional)
async function createSamplePostOfficeForFeedback(id = `sample-po-fb-${Date.now()}`) {
    const poData = {
        postOfficeId: id,
        name: `Sample PO for Feedback ${id}`,
        // ... other necessary PO fields if your model/logic requires them
    };
    await admin.database().ref(`postOffices/${id}`).set(poData);
    return poData;
}


describe('Feedback Routes', () => {
  let regularUserData;
  let adminUserData;
  let sampleFeedback1; // To store a created feedback for later tests
  let testPostOffice; // For feedback associated with a PO

  const REGULAR_USER_TOKEN = 'mock-token-feedback-user';
  const ADMIN_USER_TOKEN = 'mock-token-feedback-admin';

  beforeEach(async () => {
    if (!admin.auth() || typeof admin.auth().verifyIdToken !== 'function') {
        if (admin.auth()) { admin.auth().verifyIdToken = jest.fn(); }
        else { admin.auth = jest.fn().mockReturnValue({ verifyIdToken: jest.fn() }); }
    }
    admin.auth().verifyIdToken.mockImplementation(async (token) => {
      if (token === REGULAR_USER_TOKEN) return { uid: regularUserData.uid, email: regularUserData.email };
      if (token === ADMIN_USER_TOKEN) return { uid: adminUserData.uid, email: adminUserData.email };
      const error = new Error('Mock verifyIdToken: Invalid token for feedback tests');
      error.code = 'auth/argument-error';
      throw error;
    });

    const userSuffix = Math.random().toString(36).substring(2, 9);
    regularUserData = { uid: `reguser-fb-${userSuffix}`, email: `reguser-fb-${userSuffix}@example.com`, role: USER_ROLES.USER, displayName: 'Feedback Test User' };
    adminUserData = { uid: `admin-fb-${userSuffix}`, email: `admin-fb-${userSuffix}@example.com`, role: USER_ROLES.ADMIN, displayName: 'Feedback Test Admin' };

    await admin.database().ref('users').set(null);
    await admin.database().ref('postOffices').set(null);
    await admin.database().ref('feedback').set(null);

    await admin.database().ref(`users/${regularUserData.uid}`).set(regularUserData);
    await admin.database().ref(`users/${adminUserData.uid}`).set(adminUserData);

    testPostOffice = await createSamplePostOfficeForFeedback();

    // Create a sample feedback for regularUserData
    const feedbackInput1 = createFeedbackInputData({ postOfficeId: testPostOffice.postOfficeId, subject: "Initial Feedback Subject"});
    const feedbackRef1 = admin.database().ref('feedback').push();
    sampleFeedback1 = {
        feedbackId: feedbackRef1.key,
        userId: regularUserData.uid,
        ...feedbackInput1,
        status: FEEDBACK_STATUS.NEW,
        submittedAt: new Date().toISOString(),
        adminResponse: null,
    };
    await feedbackRef1.set(sampleFeedback1);
  });

  // --- POST /api/feedback/ (Submit Feedback - User) ---
  describe('POST /api/feedback/', () => {
    it('should allow a user to submit feedback', async () => {
      const feedbackInput = createFeedbackInputData({ postOfficeId: testPostOffice.postOfficeId });
      const res = await request(app)
        .post('/api/feedback')
        .set('Authorization', `Bearer ${REGULAR_USER_TOKEN}`)
        .send(feedbackInput);

      expect(res.statusCode).toEqual(201);
      expect(res.body).toHaveProperty('feedbackId');
      const createdFeedback = res.body;
      expect(createdFeedback.userId).toEqual(regularUserData.uid);
      expect(createdFeedback.subject).toEqual(feedbackInput.subject);
      expect(createdFeedback.status).toEqual(FEEDBACK_STATUS.NEW);

      const dbSnapshot = await admin.database().ref(`feedback/${createdFeedback.feedbackId}`).once('value');
      expect(dbSnapshot.exists()).toBe(true);
      expect(dbSnapshot.val().subject).toEqual(feedbackInput.subject);
    });

    it('should allow feedback without a postOfficeId', async () => {
        const feedbackInput = createFeedbackInputData({ postOfficeId: null }); // or omit it
        const res = await request(app)
          .post('/api/feedback')
          .set('Authorization', `Bearer ${REGULAR_USER_TOKEN}`)
          .send(feedbackInput);
        expect(res.statusCode).toEqual(201);
        expect(res.body.postOfficeId).toBeNull();
    });

    it('should return 400 for invalid feedback data', async () => {
      const res = await request(app)
        .post('/api/feedback')
        .set('Authorization', `Bearer ${REGULAR_USER_TOKEN}`)
        .send({ subject: "Ok", message: "Short" }); // Invalid length
      expect(res.statusCode).toEqual(400);
    });
  });

  // --- GET /api/feedback/my-feedback (User) ---
  describe('GET /api/feedback/my-feedback', () => {
    it('should get feedback submitted by the authenticated user', async () => {
      const res = await request(app)
        .get('/api/feedback/my-feedback')
        .set('Authorization', `Bearer ${REGULAR_USER_TOKEN}`);

      expect(res.statusCode).toEqual(200);
      expect(Array.isArray(res.body)).toBe(true);
      expect(res.body.length).toBe(1);
      expect(res.body[0].feedbackId).toEqual(sampleFeedback1.feedbackId);
    });
  });

  // --- GET /api/feedback/admin/all (Admin) ---
  describe('GET /api/feedback/admin/all', () => {
    it('should allow an admin to get all feedback', async () => {
      // Create another feedback from a different user (or admin) for variety
      const feedbackInput2 = createFeedbackInputData({ userId: adminUserData.uid, subject: "Admin's Feedback" });
      const feedbackRef2 = admin.database().ref('feedback').push();
      await feedbackRef2.set({ ...feedbackInput2, feedbackId: feedbackRef2.key, status: FEEDBACK_STATUS.NEW, userId: adminUserData.uid });


      const res = await request(app)
        .get('/api/feedback/admin/all')
        .set('Authorization', `Bearer ${ADMIN_USER_TOKEN}`);

      expect(res.statusCode).toEqual(200);
      expect(res.body).toHaveProperty('data');
      expect(res.body.data.length).toBeGreaterThanOrEqual(2);
    });

    it('should allow admin to filter feedback by status', async () => {
        await admin.database().ref(`feedback/${sampleFeedback1.feedbackId}`).update({ status: FEEDBACK_STATUS.RESOLVED });
        const res = await request(app)
          .get(`/api/feedback/admin/all?status=${FEEDBACK_STATUS.RESOLVED}`)
          .set('Authorization', `Bearer ${ADMIN_USER_TOKEN}`);
        expect(res.statusCode).toEqual(200);
        expect(res.body.data.length).toBe(1);
        expect(res.body.data[0].status).toEqual(FEEDBACK_STATUS.RESOLVED);
    });
    
    it('should allow admin to filter feedback by postOfficeId', async () => {
        const feedbackInputNoPO = createFeedbackInputData({ postOfficeId: null, subject: "General Feedback" });
        const feedbackRefNoPO = admin.database().ref('feedback').push();
        await feedbackRefNoPO.set({ ...feedbackInputNoPO, feedbackId: feedbackRefNoPO.key, userId: regularUserData.uid, status: FEEDBACK_STATUS.NEW });

        const res = await request(app)
          .get(`/api/feedback/admin/all?postOfficeId=${testPostOffice.postOfficeId}`)
          .set('Authorization', `Bearer ${ADMIN_USER_TOKEN}`);
        expect(res.statusCode).toEqual(200);
        expect(res.body.data.length).toBe(1); // Only sampleFeedback1 is associated with testPostOffice
        expect(res.body.data[0].postOfficeId).toEqual(testPostOffice.postOfficeId);
    });
  });

  // --- PUT /api/feedback/admin/:feedbackId/status (Admin) ---
  describe('PUT /api/feedback/admin/:feedbackId/status', () => {
    it('should allow an admin to update feedback status and add a response', async () => {
      const newStatus = FEEDBACK_STATUS.UNDER_REVIEW;
      const adminResponseText = "Thank you for your feedback. We are looking into this.";
      const res = await request(app)
        .put(`/api/feedback/admin/${sampleFeedback1.feedbackId}/status`)
        .set('Authorization', `Bearer ${ADMIN_USER_TOKEN}`)
        .send({ status: newStatus, adminResponse: adminResponseText });

      expect(res.statusCode).toEqual(200);
      expect(res.body.status).toEqual(newStatus);
      expect(res.body.adminResponse).toEqual(adminResponseText);

      const dbSnapshot = await admin.database().ref(`feedback/${sampleFeedback1.feedbackId}`).once('value');
      expect(dbSnapshot.val().status).toEqual(newStatus);
      expect(dbSnapshot.val().adminResponse).toEqual(adminResponseText);
    });

    it('should return 404 if admin tries to update non-existent feedback', async () => {
        const res = await request(app)
          .put('/api/feedback/admin/nonexistent-feedback-id/status')
          .set('Authorization', `Bearer ${ADMIN_USER_TOKEN}`)
          .send({ status: FEEDBACK_STATUS.CLOSED });
        expect(res.statusCode).toEqual(404);
    });
    
    it('should return 400 for invalid status update', async () => {
        const res = await request(app)
          .put(`/api/feedback/admin/${sampleFeedback1.feedbackId}/status`)
          .set('Authorization', `Bearer ${ADMIN_USER_TOKEN}`)
          .send({ status: "INVALID_STATUS_FEEDBACK" });
        expect(res.statusCode).toEqual(400);
    });
  });
});