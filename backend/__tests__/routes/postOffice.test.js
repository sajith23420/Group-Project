// __tests__/routes/postOffice.test.js

// No need to mock fs or uuid for postOffice routes as they don't handle file uploads directly.

const request = require('supertest');
const app = require('../../app');
const admin = require('../../src/config/firebaseAdmin'); // REAL admin object
const { USER_ROLES, POST_OFFICE_SERVICES } = require('../../src/config/constants');

// Helper to create post office data
function createPostOfficeData(overrides = {}) {
  const randomSuffix = Math.random().toString(36).substring(2, 7);
  return {
    name: `Test Post Office ${randomSuffix}`,
    postalCode: `${Math.floor(10000 + Math.random() * 90000)}`, // 5-digit random
    address: `123 Test Street, Test City ${randomSuffix}`,
    contactNumber: `011${Math.floor(1000000 + Math.random() * 9000000)}`,
    postmasterName: `Mr. Postmaster ${randomSuffix}`,
    servicesOffered: [POST_OFFICE_SERVICES.MAIL, POST_OFFICE_SERVICES.MONEY_ORDER],
    operatingHours: "Mon-Fri 9am-5pm, Sat 9am-1pm",
    latitude: 6.9271 + (Math.random() * 0.1 - 0.05), // Colombo area
    longitude: 79.8612 + (Math.random() * 0.1 - 0.05), // Colombo area
    subPostOfficeIds: [],
    ...overrides,
  };
}


describe('Post Office Routes', () => {
  let regularUserData;
  let adminUserData;
  let samplePostOfficeData1;
  let samplePostOfficeData2;

  const REGULAR_USER_TOKEN = 'mock-token-po-user';
  const ADMIN_USER_TOKEN = 'mock-token-po-admin';

  beforeEach(async () => {
    // Mock admin.auth().verifyIdToken behavior
    if (!admin.auth() || typeof admin.auth().verifyIdToken !== 'function') {
        if (admin.auth()) { admin.auth().verifyIdToken = jest.fn(); }
        else { admin.auth = jest.fn().mockReturnValue({ verifyIdToken: jest.fn() }); }
    }
    admin.auth().verifyIdToken.mockImplementation(async (token) => {
      if (token === REGULAR_USER_TOKEN) return { uid: regularUserData.uid, email: regularUserData.email };
      if (token === ADMIN_USER_TOKEN) return { uid: adminUserData.uid, email: adminUserData.email };
      const error = new Error('Mock verifyIdToken: Invalid token');
      error.code = 'auth/argument-error';
      throw error;
    });

    // Create user data for different roles
    const userSuffix = Math.random().toString(36).substring(2, 9);
    regularUserData = { uid: `reguser-po-${userSuffix}`, email: `reguser-po-${userSuffix}@example.com`, role: USER_ROLES.USER, displayName: 'PO Test User' };
    adminUserData = { uid: `admin-po-${userSuffix}`, email: `admin-po-${userSuffix}@example.com`, role: USER_ROLES.ADMIN, displayName: 'PO Test Admin' };

    // Clear and setup database
    // Note: jest.setup.js clears the entire DB in its beforeAll.
    // Here, we'll clear specific paths relevant to these tests and set up initial data.
    await admin.database().ref('users').set(null);
    await admin.database().ref('postOffices').set(null);

    await admin.database().ref(`users/${regularUserData.uid}`).set(regularUserData);
    await admin.database().ref(`users/${adminUserData.uid}`).set(adminUserData);

    samplePostOfficeData1 = createPostOfficeData({ name: "Colombo GPO", postalCode: "00100", servicesOffered: [POST_OFFICE_SERVICES.MAIL, POST_OFFICE_SERVICES.BILL_PAYMENT] });
    samplePostOfficeData2 = createPostOfficeData({ name: "Kandy Post Office", postalCode: "20000", servicesOffered: [POST_OFFICE_SERVICES.MONEY_ORDER] });

    const poRef1 = admin.database().ref('postOffices').push();
    samplePostOfficeData1.id = poRef1.key;
    await poRef1.set({ ...samplePostOfficeData1, postOfficeId: poRef1.key }); // Store with ID

    const poRef2 = admin.database().ref('postOffices').push();
    samplePostOfficeData2.id = poRef2.key;
    await poRef2.set({ ...samplePostOfficeData2, postOfficeId: poRef2.key });
  });

  // --- POST /api/post-offices/ (Create Post Office - Admin only) ---
  describe('POST /api/post-offices/', () => {
    it('should allow an admin to create a new post office', async () => {
      const newPostOffice = createPostOfficeData({ name: "Galle Fort PO", postalCode: "80000" });
      const res = await request(app)
        .post('/api/post-offices')
        .set('Authorization', `Bearer ${ADMIN_USER_TOKEN}`)
        .send(newPostOffice);

      expect(res.statusCode).toEqual(201);
      expect(res.body).toHaveProperty('postOfficeId');
      expect(res.body.name).toEqual(newPostOffice.name);

      const dbSnapshot = await admin.database().ref(`postOffices/${res.body.postOfficeId}`).once('value');
      expect(dbSnapshot.exists()).toBe(true);
      expect(dbSnapshot.val().name).toEqual(newPostOffice.name);
    });

    it('should return 400 for invalid post office data', async () => {
      const invalidData = { name: "Short" }; // Missing required fields
      const res = await request(app)
        .post('/api/post-offices')
        .set('Authorization', `Bearer ${ADMIN_USER_TOKEN}`)
        .send(invalidData);
      expect(res.statusCode).toEqual(400);
      expect(res.body).toHaveProperty('error', 'Validation failed');
    });

    it('should return 403 if a non-admin tries to create a post office', async () => {
      const newPostOffice = createPostOfficeData();
      const res = await request(app)
        .post('/api/post-offices')
        .set('Authorization', `Bearer ${REGULAR_USER_TOKEN}`)
        .send(newPostOffice);
      expect(res.statusCode).toEqual(403);
    });

    it('should return 401 if no token is provided for creating a post office', async () => {
        const newPostOffice = createPostOfficeData();
        const res = await request(app)
          .post('/api/post-offices')
          .send(newPostOffice);
        expect(res.statusCode).toEqual(401);
    });
  });

  // --- GET /api/post-offices/:postOfficeId (Get Post Office by ID - Public) ---
  describe('GET /api/post-offices/:postOfficeId', () => {
    it('should get a specific post office by ID', async () => {
      const res = await request(app)
        .get(`/api/post-offices/${samplePostOfficeData1.id}`);

      expect(res.statusCode).toEqual(200);
      expect(res.body).toHaveProperty('postOfficeId', samplePostOfficeData1.id);
      expect(res.body.name).toEqual(samplePostOfficeData1.name);
    });

    it('should return 404 if post office ID does not exist', async () => {
      const res = await request(app)
        .get('/api/post-offices/nonexistent-id');
      expect(res.statusCode).toEqual(404);
    });
  });

  // --- GET /api/post-offices/ (Get All Post Offices / Search - Public) ---
  describe('GET /api/post-offices/ and GET /api/post-offices/search', () => {
    it('should get all post offices (default limit)', async () => {
      const res = await request(app).get('/api/post-offices/');
      expect(res.statusCode).toEqual(200);
      expect(res.body).toHaveProperty('data');
      expect(Array.isArray(res.body.data)).toBe(true);
      expect(res.body.data.length).toBeGreaterThanOrEqual(2); // samplePostOfficeData1 & 2
      expect(res.body.total).toBeGreaterThanOrEqual(2);
    });

    it('should search post offices by name', async () => {
      const res = await request(app).get('/api/post-offices/search?name=Colombo');
      expect(res.statusCode).toEqual(200);
      expect(res.body.data.length).toBe(1);
      expect(res.body.data[0].name).toEqual(samplePostOfficeData1.name);
    });

    it('should search post offices by postal code', async () => {
      const res = await request(app).get(`/api/post-offices/search?postalCode=${samplePostOfficeData2.postalCode}`);
      expect(res.statusCode).toEqual(200);
      expect(res.body.data.length).toBe(1);
      expect(res.body.data[0].postalCode).toEqual(samplePostOfficeData2.postalCode);
    });

    it('should search post offices by service', async () => {
      const res = await request(app).get(`/api/post-offices/search?service=${POST_OFFICE_SERVICES.BILL_PAYMENT}`);
      expect(res.statusCode).toEqual(200);
      expect(res.body.data.length).toBe(1);
      expect(res.body.data[0].servicesOffered).toContain(POST_OFFICE_SERVICES.BILL_PAYMENT);
    });

    it('should handle pagination (limit and offset)', async () => {
      const res = await request(app).get('/api/post-offices?limit=1&offset=1');
      expect(res.statusCode).toEqual(200);
      expect(res.body.data.length).toBe(1);
      // The order isn't guaranteed unless specified, so we just check length
    });

    it('should return empty data array if search yields no results', async () => {
        const res = await request(app).get('/api/post-offices/search?name=NonExistentPO');
        expect(res.statusCode).toEqual(200);
        expect(res.body.data.length).toBe(0);
        expect(res.body.total).toBe(0);
    });
  });


  // --- PUT /api/post-offices/:postOfficeId (Update Post Office - Admin only) ---
  describe('PUT /api/post-offices/:postOfficeId', () => {
    it('should allow an admin to update a post office', async () => {
      const updates = { name: "Colombo GPO Updated", contactNumber: "0112223334" };
      const res = await request(app)
        .put(`/api/post-offices/${samplePostOfficeData1.id}`)
        .set('Authorization', `Bearer ${ADMIN_USER_TOKEN}`)
        .send(updates);

      expect(res.statusCode).toEqual(200);
      expect(res.body.name).toEqual(updates.name);
      expect(res.body.contactNumber).toEqual(updates.contactNumber);

      const dbSnapshot = await admin.database().ref(`postOffices/${samplePostOfficeData1.id}`).once('value');
      expect(dbSnapshot.val().name).toEqual(updates.name);
    });

    it('should return 404 if admin tries to update a non-existent post office', async () => {
      const updates = { name: "NonExistent Update" };
      const res = await request(app)
        .put('/api/post-offices/nonexistent-id-for-update')
        .set('Authorization', `Bearer ${ADMIN_USER_TOKEN}`)
        .send(updates);
      expect(res.statusCode).toEqual(404);
    });

    it('should return 403 if a non-admin tries to update a post office', async () => {
      const updates = { name: "Attempted Update" };
      const res = await request(app)
        .put(`/api/post-offices/${samplePostOfficeData1.id}`)
        .set('Authorization', `Bearer ${REGULAR_USER_TOKEN}`)
        .send(updates);
      expect(res.statusCode).toEqual(403);
    });
  });

  // --- DELETE /api/post-offices/:postOfficeId (Delete Post Office - Admin only) ---
  describe('DELETE /api/post-offices/:postOfficeId', () => {
    it('should allow an admin to delete a post office', async () => {
      const res = await request(app)
        .delete(`/api/post-offices/${samplePostOfficeData1.id}`)
        .set('Authorization', `Bearer ${ADMIN_USER_TOKEN}`);

      expect(res.statusCode).toEqual(200);
      expect(res.body.message).toEqual('Post office deleted successfully.');

      const dbSnapshot = await admin.database().ref(`postOffices/${samplePostOfficeData1.id}`).once('value');
      expect(dbSnapshot.exists()).toBe(false);
    });

    it('should return 404 if admin tries to delete a non-existent post office', async () => {
      const res = await request(app)
        .delete('/api/post-offices/nonexistent-id-for-delete')
        .set('Authorization', `Bearer ${ADMIN_USER_TOKEN}`);
      expect(res.statusCode).toEqual(404);
    });

    it('should return 403 if a non-admin tries to delete a post office', async () => {
      const res = await request(app)
        .delete(`/api/post-offices/${samplePostOfficeData2.id}`)
        .set('Authorization', `Bearer ${REGULAR_USER_TOKEN}`);
      expect(res.statusCode).toEqual(403);
    });
  });

});