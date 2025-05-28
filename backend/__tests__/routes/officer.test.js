// __tests__/routes/officer.test.js

const request = require('supertest');
const app = require('../../app');
const admin = require('../../src/config/firebaseAdmin'); // REAL admin object
const { USER_ROLES } = require('../../src/config/constants');

// Helper to create officer data
function createOfficerData(overrides = {}) {
  const randomSuffix = Math.random().toString(36).substring(2, 7);
  return {
    name: `Officer ${randomSuffix}`,
    designation: `Postmaster Grade ${Math.floor(1 + Math.random() * 3)}`,
    assignedPostOfficeId: `po-id-${randomSuffix}`, // Should be a valid ID from your postOffices setup
    contactNumber: `071${Math.floor(1000000 + Math.random() * 9000000)}`,
    email: `officer.${randomSuffix}@slpost.lk`,
    photoUrl: `http://example.com/photos/officer_${randomSuffix}.jpg`,
    ...overrides,
  };
}

// Helper to create post office data (minimal, just for assignedPostOfficeId reference)
async function createSamplePostOffice(id = `sample-po-${Date.now()}`) {
    const poData = {
        postOfficeId: id,
        name: `Sample PO ${id}`,
        postalCode: "99999",
        address: "1 Sample St",
        servicesOffered: ["Mail"],
        operatingHours: "9-5",
        latitude: 0,
        longitude: 0,
    };
    await admin.database().ref(`postOffices/${id}`).set(poData);
    return poData;
}


describe('Officer Routes', () => {
  let regularUserData;
  let adminUserData;
  let sampleOfficerData1;
  let sampleOfficerData2;
  let samplePostOffice1;
  let samplePostOffice2;


  const REGULAR_USER_TOKEN = 'mock-token-officer-user';
  const ADMIN_USER_TOKEN = 'mock-token-officer-admin';

  beforeEach(async () => {
    if (!admin.auth() || typeof admin.auth().verifyIdToken !== 'function') {
        if (admin.auth()) { admin.auth().verifyIdToken = jest.fn(); }
        else { admin.auth = jest.fn().mockReturnValue({ verifyIdToken: jest.fn() }); }
    }
    admin.auth().verifyIdToken.mockImplementation(async (token) => {
      if (token === REGULAR_USER_TOKEN) return { uid: regularUserData.uid, email: regularUserData.email };
      if (token === ADMIN_USER_TOKEN) return { uid: adminUserData.uid, email: adminUserData.email };
      const error = new Error('Mock verifyIdToken: Invalid token for officer tests');
      error.code = 'auth/argument-error';
      throw error;
    });

    const userSuffix = Math.random().toString(36).substring(2, 9);
    regularUserData = { uid: `reguser-officer-${userSuffix}`, email: `reguser-officer-${userSuffix}@example.com`, role: USER_ROLES.USER, displayName: 'Officer Test User' };
    adminUserData = { uid: `admin-officer-${userSuffix}`, email: `admin-officer-${userSuffix}@example.com`, role: USER_ROLES.ADMIN, displayName: 'Officer Test Admin' };

    await admin.database().ref('users').set(null);
    await admin.database().ref('officers').set(null);
    await admin.database().ref('postOffices').set(null); // Clear post offices too

    await admin.database().ref(`users/${regularUserData.uid}`).set(regularUserData);
    await admin.database().ref(`users/${adminUserData.uid}`).set(adminUserData);

    samplePostOffice1 = await createSamplePostOffice('po123');
    samplePostOffice2 = await createSamplePostOffice('po456');

    sampleOfficerData1 = createOfficerData({ name: "John Doe", assignedPostOfficeId: samplePostOffice1.postOfficeId });
    sampleOfficerData2 = createOfficerData({ name: "Jane Smith", assignedPostOfficeId: samplePostOffice2.postOfficeId });

    const officerRef1 = admin.database().ref('officers').push();
    sampleOfficerData1.id = officerRef1.key; // Officer's own unique ID
    await officerRef1.set({ ...sampleOfficerData1, officerId: officerRef1.key });

    const officerRef2 = admin.database().ref('officers').push();
    sampleOfficerData2.id = officerRef2.key;
    await officerRef2.set({ ...sampleOfficerData2, officerId: officerRef2.key });
  });

  // --- POST /api/officers/ (Create Officer - Admin only) ---
  describe('POST /api/officers/', () => {
    it('should allow an admin to create a new officer', async () => {
      const newOfficer = createOfficerData({ name: "Alice Brown", assignedPostOfficeId: samplePostOffice1.postOfficeId });
      const res = await request(app)
        .post('/api/officers')
        .set('Authorization', `Bearer ${ADMIN_USER_TOKEN}`)
        .send(newOfficer);

      expect(res.statusCode).toEqual(201);
      expect(res.body).toHaveProperty('officerId');
      expect(res.body.name).toEqual(newOfficer.name);
      expect(res.body.assignedPostOfficeId).toEqual(samplePostOffice1.postOfficeId);

      const dbSnapshot = await admin.database().ref(`officers/${res.body.officerId}`).once('value');
      expect(dbSnapshot.exists()).toBe(true);
      expect(dbSnapshot.val().name).toEqual(newOfficer.name);
    });

    it('should return 400 for invalid officer data', async () => {
      const invalidData = { name: "S" }; // Missing required fields, name too short
      const res = await request(app)
        .post('/api/officers')
        .set('Authorization', `Bearer ${ADMIN_USER_TOKEN}`)
        .send(invalidData);
      expect(res.statusCode).toEqual(400);
    });

    it('should return 403 if a non-admin tries to create an officer', async () => {
      const newOfficer = createOfficerData();
      const res = await request(app)
        .post('/api/officers')
        .set('Authorization', `Bearer ${REGULAR_USER_TOKEN}`)
        .send(newOfficer);
      expect(res.statusCode).toEqual(403);
    });
  });

  // --- GET /api/officers/:officerId (Get Officer by ID - Public) ---
  describe('GET /api/officers/:officerId', () => {
    it('should get a specific officer by ID', async () => {
      const res = await request(app)
        .get(`/api/officers/${sampleOfficerData1.id}`);

      expect(res.statusCode).toEqual(200);
      expect(res.body).toHaveProperty('officerId', sampleOfficerData1.id);
      expect(res.body.name).toEqual(sampleOfficerData1.name);
    });

    it('should return 404 if officer ID does not exist', async () => {
      const res = await request(app)
        .get('/api/officers/nonexistent-officer-id');
      expect(res.statusCode).toEqual(404);
    });
  });

  // --- GET /api/officers/ (Get All Officers - Public) ---
  describe('GET /api/officers/', () => {
    it('should get all officers', async () => {
      const res = await request(app).get('/api/officers/');
      expect(res.statusCode).toEqual(200);
      expect(Array.isArray(res.body)).toBe(true);
      expect(res.body.length).toBeGreaterThanOrEqual(2); // sampleOfficerData1 & 2
      const officerNames = res.body.map(o => o.name);
      expect(officerNames).toContain(sampleOfficerData1.name);
      expect(officerNames).toContain(sampleOfficerData2.name);
    });
  });

  // --- GET /api/officers/by-post-office/:postOfficeId (Get Officers by Post Office ID - Public) ---
  describe('GET /api/officers/by-post-office/:postOfficeId', () => {
    it('should get officers for a specific post office', async () => {
      const res = await request(app)
        .get(`/api/officers/by-post-office/${samplePostOffice1.postOfficeId}`);

      expect(res.statusCode).toEqual(200);
      expect(Array.isArray(res.body)).toBe(true);
      expect(res.body.length).toBe(1);
      expect(res.body[0].name).toEqual(sampleOfficerData1.name);
    });

    it('should return 404 if no officers found for a post office ID', async () => {
      const newPO = await createSamplePostOffice('po789-no-officers');
      const res = await request(app)
        .get(`/api/officers/by-post-office/${newPO.postOfficeId}`);
      expect(res.statusCode).toEqual(404);
      expect(res.body.message).toEqual('No officers found for this post office.');
    });

    it('should return 404 if the post office ID itself does not exist (implicitly no officers)', async () => {
        const res = await request(app)
          .get(`/api/officers/by-post-office/nonexistent-po-id`);
        // The controller currently doesn't check if the PO itself exists, just if officers are assigned.
        // So this might return 404 with "no officers found" or an empty array depending on implementation.
        // Let's assume 404 "No officers found" based on current controller logic.
        expect(res.statusCode).toEqual(404);
        expect(res.body.message).toEqual('No officers found for this post office.');
      });
  });

  // --- PUT /api/officers/:officerId (Update Officer - Admin only) ---
  describe('PUT /api/officers/:officerId', () => {
    it('should allow an admin to update an officer', async () => {
      const updates = { name: "Johnathan Doe Updated", designation: "Senior Postmaster" };
      const res = await request(app)
        .put(`/api/officers/${sampleOfficerData1.id}`)
        .set('Authorization', `Bearer ${ADMIN_USER_TOKEN}`)
        .send(updates);

      expect(res.statusCode).toEqual(200);
      expect(res.body.name).toEqual(updates.name);
      expect(res.body.designation).toEqual(updates.designation);

      const dbSnapshot = await admin.database().ref(`officers/${sampleOfficerData1.id}`).once('value');
      expect(dbSnapshot.val().name).toEqual(updates.name);
    });

    it('should return 404 if admin tries to update a non-existent officer', async () => {
      const updates = { name: "NonExistent Officer Update" };
      const res = await request(app)
        .put('/api/officers/nonexistent-officer-for-update')
        .set('Authorization', `Bearer ${ADMIN_USER_TOKEN}`)
        .send(updates);
      expect(res.statusCode).toEqual(404);
    });

    it('should return 403 if a non-admin tries to update an officer', async () => {
      const updates = { name: "Illegal Update Attempt" };
      const res = await request(app)
        .put(`/api/officers/${sampleOfficerData1.id}`)
        .set('Authorization', `Bearer ${REGULAR_USER_TOKEN}`)
        .send(updates);
      expect(res.statusCode).toEqual(403);
    });
  });

  // --- DELETE /api/officers/:officerId (Delete Officer - Admin only) ---
  describe('DELETE /api/officers/:officerId', () => {
    it('should allow an admin to delete an officer', async () => {
      const res = await request(app)
        .delete(`/api/officers/${sampleOfficerData1.id}`)
        .set('Authorization', `Bearer ${ADMIN_USER_TOKEN}`);

      expect(res.statusCode).toEqual(200);
      expect(res.body.message).toEqual('Officer deleted successfully.');

      const dbSnapshot = await admin.database().ref(`officers/${sampleOfficerData1.id}`).once('value');
      expect(dbSnapshot.exists()).toBe(false);
    });

    it('should return 404 if admin tries to delete a non-existent officer', async () => {
      const res = await request(app)
        .delete('/api/officers/nonexistent-officer-for-delete')
        .set('Authorization', `Bearer ${ADMIN_USER_TOKEN}`);
      expect(res.statusCode).toEqual(404);
    });

    it('should return 403 if a non-admin tries to delete an officer', async () => {
      const res = await request(app)
        .delete(`/api/officers/${sampleOfficerData2.id}`)
        .set('Authorization', `Bearer ${REGULAR_USER_TOKEN}`);
      expect(res.statusCode).toEqual(403);
    });
  });
});