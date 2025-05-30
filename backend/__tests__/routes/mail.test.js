const request = require('supertest');
const app = require('../../app');
const admin = require('../../src/config/firebaseAdmin');
const { USER_ROLES, PARCEL_STATUS } = require('../../src/config/constants');

describe('Mail Routes', () => {
  let regularUserData, adminUserData, sampleMail;
  const REGULAR_USER_TOKEN = 'mock-token-mail-user';
  const ADMIN_USER_TOKEN = 'mock-token-mail-admin';

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
    regularUserData = { uid: `reguser-mail-${userSuffix}`, email: `reguser-mail-${userSuffix}@example.com`, role: USER_ROLES.USER };
    adminUserData = { uid: `admin-mail-${userSuffix}`, email: `admin-mail-${userSuffix}@example.com`, role: USER_ROLES.ADMIN };

    await admin.database().ref('users').set(null);
    await admin.database().ref('mails').set(null);
    await admin.database().ref(`users/${regularUserData.uid}`).set(regularUserData);
    await admin.database().ref(`users/${adminUserData.uid}`).set(adminUserData);

    // Create a sample mail for GET/PUT tests
    const mailRef = admin.database().ref('mails').push();
    sampleMail = {
      mailId: mailRef.key,
      userId: regularUserData.uid,
      senderName: "Sender",
      receiverName: "Receiver",
      receiverAddress: "123 Main St",
      weight: 2.5,
      status: PARCEL_STATUS.PENDING,
      createdBy: adminUserData.uid,
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString(),
    };
    await mailRef.set(sampleMail);
  });

  it('should allow admin to create a mail/parcel', async () => {
    const res = await request(app)
      .post('/api/mails')
      .set('Authorization', `Bearer ${ADMIN_USER_TOKEN}`)
      .send({
        userId: regularUserData.uid,
        senderName: "Sender",
        receiverName: "Receiver",
        receiverAddress: "456 New St",
        weight: 1.2
      });
    expect(res.statusCode).toBe(201);
    expect(res.body.mail.userId).toBe(regularUserData.uid);
    expect(res.body.mail.status).toBe(PARCEL_STATUS.PENDING);
  });

  it('should allow user to get their mails/parcels', async () => {
    const res = await request(app)
      .get('/api/mails/my-mails')
      .set('Authorization', `Bearer ${REGULAR_USER_TOKEN}`);
    expect(res.statusCode).toBe(200);
    expect(Array.isArray(res.body)).toBe(true);
    expect(res.body[0].mailId).toBe(sampleMail.mailId);
  });

  it('should allow admin to update mail/parcel status', async () => {
    const res = await request(app)
      .put(`/api/mails/admin/${sampleMail.mailId}/status`)
      .set('Authorization', `Bearer ${ADMIN_USER_TOKEN}`)
      .send({ status: PARCEL_STATUS.SENT });
    expect(res.statusCode).toBe(200);
    const dbSnapshot = await admin.database().ref(`mails/${sampleMail.mailId}`).once('value');
    expect(dbSnapshot.val().status).toBe(PARCEL_STATUS.SENT);
  });

  it('should allow admin to get all mails/parcels', async () => {
    const res = await request(app)
      .get('/api/mails/admin/all')
      .set('Authorization', `Bearer ${ADMIN_USER_TOKEN}`);
    expect(res.statusCode).toBe(200);
    expect(Array.isArray(res.body)).toBe(true);
    expect(res.body[0].mailId).toBe(sampleMail.mailId);
  });
});