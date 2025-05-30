// __tests__/routes/billPayment.test.js

const request = require('supertest');
const app = require('../../app');
const admin = require('../../src/config/firebaseAdmin'); // REAL admin object
const { USER_ROLES, BILL_PAYMENT_STATUS, BILL_TYPES } = require('../../src/config/constants');

// Helper to create bill payment input data
function createBillPaymentInputData(overrides = {}) {
  const randomSuffix = Math.random().toString(36).substring(2, 7);
  return {
    billType: BILL_TYPES.OSF, // Default to OSF, can be overridden
    billReferenceNumber: `REF-${randomSuffix}-${Date.now()}`,
    billerName: `Utility Co ${randomSuffix}`,
    amount: parseFloat((50 + Math.random() * 450).toFixed(2)), // Amount between 50.00 and 500.00
    ...overrides,
  };
}

describe('Bill Payment Routes', () => {
  let regularUserData;
  let adminUserData;
  let sampleBillPayment1; // To store the full bill payment object created

  const REGULAR_USER_TOKEN = 'mock-token-bp-user';
  const ADMIN_USER_TOKEN = 'mock-token-bp-admin';

  beforeEach(async () => {
    if (!admin.auth() || typeof admin.auth().verifyIdToken !== 'function') {
        if (admin.auth()) { admin.auth().verifyIdToken = jest.fn(); }
        else { admin.auth = jest.fn().mockReturnValue({ verifyIdToken: jest.fn() }); }
    }
    admin.auth().verifyIdToken.mockImplementation(async (token) => {
      if (token === REGULAR_USER_TOKEN) return { uid: regularUserData.uid, email: regularUserData.email };
      if (token === ADMIN_USER_TOKEN) return { uid: adminUserData.uid, email: adminUserData.email };
      const error = new Error('Mock verifyIdToken: Invalid token for bill payment tests');
      error.code = 'auth/argument-error';
      throw error;
    });

    const userSuffix = Math.random().toString(36).substring(2, 9);
    regularUserData = { uid: `reguser-bp-${userSuffix}`, email: `reguser-bp-${userSuffix}@example.com`, role: USER_ROLES.USER, displayName: 'BP Test User' };
    adminUserData = { uid: `admin-bp-${userSuffix}`, email: `admin-bp-${userSuffix}@example.com`, role: USER_ROLES.ADMIN, displayName: 'BP Test Admin' };

    await admin.database().ref('users').set(null);
    await admin.database().ref('billPayments').set(null);

    await admin.database().ref(`users/${regularUserData.uid}`).set(regularUserData);
    await admin.database().ref(`users/${adminUserData.uid}`).set(adminUserData);

    // Create a sample bill payment for GET/PUT tests
    const inputData1 = createBillPaymentInputData({ billerName: "Initial Biller", billType: BILL_TYPES.EXAM_FEE });
    const bpRef = admin.database().ref('billPayments').push();
    sampleBillPayment1 = {
      billPaymentId: bpRef.key,
      userId: regularUserData.uid,
      ...inputData1,
      transactionId: null,
      paymentGatewayResponse: null,
      status: BILL_PAYMENT_STATUS.PENDING_PAYMENT,
      paymentDate: null,
      createdAt: new Date().toISOString(),
    };
    await bpRef.set(sampleBillPayment1);
    await admin.database().ref(`users/${regularUserData.uid}/paymentHistoryRefs/billPayments/${bpRef.key}`).set(true);
  });

  // --- GET /api/bill-payments/types (Public) ---
  describe('GET /api/bill-payments/types', () => {
    it('should return available bill types', async () => {
        const res = await request(app).get('/api/bill-payments/types');
        expect(res.statusCode).toEqual(200);
        expect(Array.isArray(res.body)).toBe(true);
        expect(res.body).toEqual(expect.arrayContaining(Object.values(BILL_TYPES)));
    });
  });

  // --- POST /api/bill-payments/initiate (User) ---
  describe('POST /api/bill-payments/initiate', () => {
    it('should allow a user to initiate a bill payment', async () => {
      const inputData = createBillPaymentInputData();
      const res = await request(app)
        .post('/api/bill-payments/initiate')
        .set('Authorization', `Bearer ${REGULAR_USER_TOKEN}`)
        .send(inputData);

      expect(res.statusCode).toEqual(201);
      expect(res.body).toHaveProperty('billPayment');
      expect(res.body.billPayment.userId).toEqual(regularUserData.uid);
      expect(res.body.billPayment.amount).toEqual(inputData.amount);
      expect(res.body.billPayment.status).toEqual(BILL_PAYMENT_STATUS.PENDING_PAYMENT);
      expect(res.body.paymentDetails.payableAmount).toEqual(inputData.amount);

      const dbSnapshot = await admin.database().ref(`billPayments/${res.body.billPayment.billPaymentId}`).once('value');
      expect(dbSnapshot.exists()).toBe(true);
      expect(dbSnapshot.val().amount).toEqual(inputData.amount);
      const userHistorySnapshot = await admin.database().ref(`users/${regularUserData.uid}/paymentHistoryRefs/billPayments/${res.body.billPayment.billPaymentId}`).once('value');
      expect(userHistorySnapshot.exists()).toBe(true);
    });

    it('should return 400 for invalid bill payment data', async () => {
      const res = await request(app)
        .post('/api/bill-payments/initiate')
        .set('Authorization', `Bearer ${REGULAR_USER_TOKEN}`)
        .send({ amount: -100, billType: "INVALID_TYPE" }); // Invalid amount and type
      expect(res.statusCode).toEqual(400);
    });
  });

  // --- POST /api/bill-payments/:billPaymentId/confirm-payment (User) ---
  describe('POST /api/bill-payments/:billPaymentId/confirm-payment', () => {
    it('should allow a user to confirm payment for a bill', async () => {
      const paymentData = {
        transactionId: "txn_bp_456def",
        paymentGatewayResponse: { details: "bill payment success" },
        status: BILL_PAYMENT_STATUS.COMPLETED,
      };
      const res = await request(app)
        .post(`/api/bill-payments/${sampleBillPayment1.billPaymentId}/confirm-payment`)
        .set('Authorization', `Bearer ${REGULAR_USER_TOKEN}`)
        .send(paymentData);

      expect(res.statusCode).toEqual(200);
      expect(res.body.status).toEqual(paymentData.status);
      expect(res.body.transactionId).toEqual(paymentData.transactionId);
      expect(res.body.paymentDate).not.toBeNull();

      const dbSnapshot = await admin.database().ref(`billPayments/${sampleBillPayment1.billPaymentId}`).once('value');
      expect(dbSnapshot.val().status).toEqual(paymentData.status);
      expect(dbSnapshot.val().paymentDate).not.toBeNull();
    });

    it('should return 404 if bill payment not found', async () => {
        const res = await request(app)
          .post('/api/bill-payments/nonexistent-bp-id/confirm-payment')
          .set('Authorization', `Bearer ${REGULAR_USER_TOKEN}`)
          .send({ transactionId: "txn_fake_bp", paymentGatewayResponse: {}, status: BILL_PAYMENT_STATUS.COMPLETED });
        expect(res.statusCode).toEqual(404);
    });

    it('should return 400 if bill payment is not in PENDING_PAYMENT state', async () => {
        await admin.database().ref(`billPayments/${sampleBillPayment1.billPaymentId}`).update({ status: BILL_PAYMENT_STATUS.FAILED });
        const res = await request(app)
          .post(`/api/bill-payments/${sampleBillPayment1.billPaymentId}/confirm-payment`)
          .set('Authorization', `Bearer ${REGULAR_USER_TOKEN}`)
          .send({ transactionId: "txn_late_bp", paymentGatewayResponse: {}, status: BILL_PAYMENT_STATUS.COMPLETED });
        expect(res.statusCode).toEqual(400);
        expect(res.body.message).toContain('Bill payment is already failed.');
    });
  });

  // --- GET /api/bill-payments/my-payments (User) ---
  describe('GET /api/bill-payments/my-payments', () => {
    it('should get bill payments for the authenticated user', async () => {
      const res = await request(app)
        .get('/api/bill-payments/my-payments')
        .set('Authorization', `Bearer ${REGULAR_USER_TOKEN}`);

      expect(res.statusCode).toEqual(200);
      expect(Array.isArray(res.body)).toBe(true);
      expect(res.body.length).toBe(1);
      expect(res.body[0].billPaymentId).toEqual(sampleBillPayment1.billPaymentId);
    });
  });

  // --- GET /api/bill-payments/:billPaymentId (User/Admin) ---
  describe('GET /api/bill-payments/:billPaymentId', () => {
    it('should get bill payment details for the owner', async () => {
      const res = await request(app)
        .get(`/api/bill-payments/${sampleBillPayment1.billPaymentId}`)
        .set('Authorization', `Bearer ${REGULAR_USER_TOKEN}`);
      expect(res.statusCode).toEqual(200);
      expect(res.body.billPaymentId).toEqual(sampleBillPayment1.billPaymentId);
    });

    it('should get bill payment details for an admin', async () => {
        const res = await request(app)
          .get(`/api/bill-payments/${sampleBillPayment1.billPaymentId}`)
          .set('Authorization', `Bearer ${ADMIN_USER_TOKEN}`);
        expect(res.statusCode).toEqual(200);
        expect(res.body.billPaymentId).toEqual(sampleBillPayment1.billPaymentId);
    });

    it('should return 403 if a different user tries to access the bill payment', async () => {
        const anotherUserSuffix = Math.random().toString(36).substring(2, 9);
        const anotherUserData = { uid: `another-bp-user-${anotherUserSuffix}`, email: `anotherbp-${anotherUserSuffix}@example.com`, role: USER_ROLES.USER };
        await admin.database().ref(`users/${anotherUserData.uid}`).set(anotherUserData);
        const ANOTHER_BP_USER_TOKEN = 'mock-token-another-bp-user';
        admin.auth().verifyIdToken.mockImplementation(async (token) => {
            if (token === ANOTHER_BP_USER_TOKEN) return { uid: anotherUserData.uid, email: anotherUserData.email };
            // Keep existing mocks for REGULAR_USER_TOKEN and ADMIN_USER_TOKEN
            if (token === REGULAR_USER_TOKEN) return { uid: regularUserData.uid, email: regularUserData.email };
            if (token === ADMIN_USER_TOKEN) return { uid: adminUserData.uid, email: adminUserData.email };
            throw new Error("unmocked token in GET /:billPaymentId");
        });

        const res = await request(app)
          .get(`/api/bill-payments/${sampleBillPayment1.billPaymentId}`)
          .set('Authorization', `Bearer ${ANOTHER_BP_USER_TOKEN}`);
        expect(res.statusCode).toEqual(403);
    });
  });

  // --- GET /api/bill-payments/admin/all (Admin) ---
  describe('GET /api/bill-payments/admin/all', () => {
    it('should allow an admin to get all bill payments', async () => {
      const res = await request(app)
        .get('/api/bill-payments/admin/all')
        .set('Authorization', `Bearer ${ADMIN_USER_TOKEN}`);

      expect(res.statusCode).toEqual(200);
      expect(res.body).toHaveProperty('data');
      expect(Array.isArray(res.body.data)).toBe(true);
      expect(res.body.data.length).toBeGreaterThanOrEqual(1);
      expect(res.body.data.find(bp => bp.billPaymentId === sampleBillPayment1.billPaymentId)).toBeDefined();
    });

     it('should allow admin to filter bill payments by billType', async () => {
        const inputDataOSF = createBillPaymentInputData({ billType: BILL_TYPES.OSF, billerName: "OSF Biller" });
        const bpRefOSF = admin.database().ref('billPayments').push();
        await bpRefOSF.set({...inputDataOSF, billPaymentId: bpRefOSF.key, userId: adminUserData.uid, status: BILL_PAYMENT_STATUS.PENDING_PAYMENT});

        const res = await request(app)
          .get(`/api/bill-payments/admin/all?billType=${BILL_TYPES.EXAM_FEE}`)
          .set('Authorization', `Bearer ${ADMIN_USER_TOKEN}`);
        
        expect(res.statusCode).toEqual(200);
        expect(res.body.data.length).toBe(1); // Only sampleBillPayment1 which is EXAM_FEE
        expect(res.body.data[0].billType).toEqual(BILL_TYPES.EXAM_FEE);
        expect(res.body.data[0].billPaymentId).toEqual(sampleBillPayment1.billPaymentId);
    });

    it('should allow admin to filter bill payments by status', async () => {
        await admin.database().ref(`billPayments/${sampleBillPayment1.billPaymentId}`).update({ status: BILL_PAYMENT_STATUS.COMPLETED });
        const inputDataPending = createBillPaymentInputData({ status: BILL_PAYMENT_STATUS.PENDING_PAYMENT });
        const bpRefPending = admin.database().ref('billPayments').push();
        await bpRefPending.set({...inputDataPending, billPaymentId: bpRefPending.key, userId: adminUserData.uid, status: BILL_PAYMENT_STATUS.PENDING_PAYMENT});


        const res = await request(app)
          .get(`/api/bill-payments/admin/all?status=${BILL_PAYMENT_STATUS.COMPLETED}`)
          .set('Authorization', `Bearer ${ADMIN_USER_TOKEN}`);
        
        expect(res.statusCode).toEqual(200);
        expect(res.body.data.length).toBe(1);
        expect(res.body.data[0].status).toEqual(BILL_PAYMENT_STATUS.COMPLETED);
    });


    it('should return 403 if non-admin tries to get all bill payments', async () => {
        const res = await request(app)
          .get('/api/bill-payments/admin/all')
          .set('Authorization', `Bearer ${REGULAR_USER_TOKEN}`);
        expect(res.statusCode).toEqual(403);
    });
  });
  // Note: BillPayment routes do not have an admin update status route like money orders.
  // If one were added, tests for it would go here.
});