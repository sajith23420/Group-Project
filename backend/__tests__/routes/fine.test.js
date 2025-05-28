const request = require('supertest');
const app = require('../../app');
const admin = require('../../src/config/firebaseAdmin');
const { USER_ROLES, FINE_STATUS } = require('../../src/config/constants');

describe('Fine Routes', () => {
  let regularUserData, adminUserData, sampleFine;
  const REGULAR_USER_TOKEN = 'mock-token-fine-user';
  const ADMIN_USER_TOKEN = 'mock-token-fine-admin';

  beforeEach(async () => {
    if (!admin.auth() || typeof admin.auth().verifyIdToken !== 'function') {
      if (admin.auth()) { admin.auth().verifyIdToken = jest.fn(); }
      else { admin.auth = jest.fn().mockReturnValue({ verifyIdToken: jest.fn() }); }
    }
    admin.auth().verifyIdToken.mockImplementation(async (token) => {
      if (token === REGULAR_USER_TOKEN) return { uid: regularUserData.uid, email: regularUserData.email };
      if (token === ADMIN_USER_TOKEN) return { uid: adminUserData.uid, email: adminUserData.email };
      throw new Error('Invalid token');
    });

    const userSuffix = Math.random().toString(36).substring(2, 9);
    regularUserData = { uid: `reguser-fine-${userSuffix}`, email: `reguser-fine-${userSuffix}@example.com`, role: USER_ROLES.USER };
    adminUserData = { uid: `admin-fine-${userSuffix}`, email: `admin-fine-${userSuffix}@example.com`, role: USER_ROLES.ADMIN };

    await admin.database().ref('users').set(null);
    await admin.database().ref('fines').set(null);
    await admin.database().ref(`users/${regularUserData.uid}`).set(regularUserData);
    await admin.database().ref(`users/${adminUserData.uid}`).set(adminUserData);

    // Create a sample fine for GET/PUT tests
    const fineRef = admin.database().ref('fines').push();
    sampleFine = {
      fineId: fineRef.key,
      userId: regularUserData.uid,
      reason: "Test fine reason",
      amount: 100,
      status: FINE_STATUS.PAYMENT_PENDING,
      createdBy: adminUserData.uid,
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString(),
    };
    await fineRef.set(sampleFine);
  });

  it('should allow admin to create a fine', async () => {
    const res = await request(app)
      .post('/api/fines')
      .set('Authorization', `Bearer ${ADMIN_USER_TOKEN}`)
      .send({ userId: regularUserData.uid, reason: "Late fee", amount: 50 });
    expect(res.statusCode).toBe(201);
    expect(res.body.fine.userId).toBe(regularUserData.uid);
    expect(res.body.fine.status).toBe(FINE_STATUS.PAYMENT_PENDING);
  });

  it('should allow user to mark fine as pay-by-customer', async () => {
    const res = await request(app)
      .put(`/api/fines/${sampleFine.fineId}/pay`)
      .set('Authorization', `Bearer ${REGULAR_USER_TOKEN}`);
    expect(res.statusCode).toBe(200);
    const dbSnapshot = await admin.database().ref(`fines/${sampleFine.fineId}`).once('value');
    expect(dbSnapshot.val().status).toBe(FINE_STATUS.PAY_BY_CUSTOMER);
  });

  it('should allow admin to update fine status to confirmed', async () => {
    await admin.database().ref(`fines/${sampleFine.fineId}`).update({ status: FINE_STATUS.PAY_BY_CUSTOMER });
    const res = await request(app)
      .put(`/api/fines/admin/${sampleFine.fineId}/status`)
      .set('Authorization', `Bearer ${ADMIN_USER_TOKEN}`)
      .send({ status: FINE_STATUS.PAYMENT_CONFIRMED });
    expect(res.statusCode).toBe(200);
    const dbSnapshot = await admin.database().ref(`fines/${sampleFine.fineId}`).once('value');
    expect(dbSnapshot.val().status).toBe(FINE_STATUS.PAYMENT_CONFIRMED);
  });

  it('should get all fines for a user', async () => {
    const res = await request(app)
      .get('/api/fines/my-fines')
      .set('Authorization', `Bearer ${REGULAR_USER_TOKEN}`);
    expect(res.statusCode).toBe(200);
    expect(Array.isArray(res.body)).toBe(true);
    expect(res.body[0].fineId).toBe(sampleFine.fineId);
  });

  it('should allow admin to get all fines', async () => {
    const res = await request(app)
      .get('/api/fines/admin/all')
      .set('Authorization', `Bearer ${ADMIN_USER_TOKEN}`);
    expect(res.statusCode).toBe(200);
    expect(Array.isArray(res.body)).toBe(true);
    expect(res.body[0].fineId).toBe(sampleFine.fineId);
  });
});