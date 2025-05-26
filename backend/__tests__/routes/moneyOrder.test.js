// __tests__/routes/moneyOrder.test.js

const request = require('supertest');
const app = require('../../app');
const admin = require('../../src/config/firebaseAdmin'); // REAL admin object
const { USER_ROLES, MONEY_ORDER_STATUS } = require('../../src/config/constants');
const MoneyOrder = require('../../src/models/moneyOrderModel'); // For data structure reference

// Helper to create money order data
function createMoneyOrderInputData(overrides = {}) {
  const randomSuffix = Math.random().toString(36).substring(2, 7);
  return {
    recipientName: `Recipient ${randomSuffix}`,
    recipientAddress: `456 Recipient Ave, Receiver City ${randomSuffix}`,
    recipientContact: `077${Math.floor(1000000 + Math.random() * 9000000)}`,
    amount: parseFloat((100 + Math.random() * 900).toFixed(2)), // Amount between 100.00 and 1000.00
    notes: `Test money order notes ${randomSuffix}`,
    ...overrides,
  };
}

describe('Money Order Routes', () => {
  let regularUserData;
  let adminUserData;
  let sampleMoneyOrder1; // To store the full money order object created

  const REGULAR_USER_TOKEN = 'mock-token-mo-user';
  const ADMIN_USER_TOKEN = 'mock-token-mo-admin';
  const SERVICE_CHARGE_PERCENTAGE = 0.02; // Keep consistent with controller

  beforeEach(async () => {
    if (!admin.auth() || typeof admin.auth().verifyIdToken !== 'function') {
        if (admin.auth()) { admin.auth().verifyIdToken = jest.fn(); }
        else { admin.auth = jest.fn().mockReturnValue({ verifyIdToken: jest.fn() }); }
    }
    admin.auth().verifyIdToken.mockImplementation(async (token) => {
      if (token === REGULAR_USER_TOKEN) return { uid: regularUserData.uid, email: regularUserData.email };
      if (token === ADMIN_USER_TOKEN) return { uid: adminUserData.uid, email: adminUserData.email };
      const error = new Error('Mock verifyIdToken: Invalid token for money order tests');
      error.code = 'auth/argument-error';
      throw error;
    });

    const userSuffix = Math.random().toString(36).substring(2, 9);
    regularUserData = { uid: `reguser-mo-${userSuffix}`, email: `reguser-mo-${userSuffix}@example.com`, role: USER_ROLES.USER, displayName: 'MO Test User' };
    adminUserData = { uid: `admin-mo-${userSuffix}`, email: `admin-mo-${userSuffix}@example.com`, role: USER_ROLES.ADMIN, displayName: 'MO Test Admin' };

    await admin.database().ref('users').set(null);
    await admin.database().ref('moneyOrders').set(null);

    await admin.database().ref(`users/${regularUserData.uid}`).set(regularUserData);
    await admin.database().ref(`users/${adminUserData.uid}`).set(adminUserData);

    // Create a sample money order for GET/PUT tests
    const inputData1 = createMoneyOrderInputData({ recipientName: "Initial Recipient" });
    const serviceCharge1 = parseFloat((inputData1.amount * SERVICE_CHARGE_PERCENTAGE).toFixed(2));
    const moRef = admin.database().ref('moneyOrders').push();
    sampleMoneyOrder1 = {
      moneyOrderId: moRef.key,
      senderUserId: regularUserData.uid,
      ...inputData1,
      serviceCharge: serviceCharge1,
      totalAmount: inputData1.amount + serviceCharge1,
      transactionId: null,
      paymentGatewayResponse: null,
      status: MONEY_ORDER_STATUS.PENDING_PAYMENT,
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString(),
    };
    await moRef.set(sampleMoneyOrder1);
    // Also add to user's payment history for completeness if needed in other tests, not strictly for MO routes
    await admin.database().ref(`users/${regularUserData.uid}/paymentHistoryRefs/moneyOrders/${moRef.key}`).set(true);

  });

  // --- POST /api/money-orders/initiate (User) ---
  describe('POST /api/money-orders/initiate', () => {
    it('should allow a user to initiate a money order', async () => {
      const inputData = createMoneyOrderInputData();
      const res = await request(app)
        .post('/api/money-orders/initiate')
        .set('Authorization', `Bearer ${REGULAR_USER_TOKEN}`)
        .send(inputData);

      expect(res.statusCode).toEqual(201);
      expect(res.body).toHaveProperty('moneyOrder');
      expect(res.body.moneyOrder.senderUserId).toEqual(regularUserData.uid);
      expect(res.body.moneyOrder.amount).toEqual(inputData.amount);
      expect(res.body.moneyOrder.status).toEqual(MONEY_ORDER_STATUS.PENDING_PAYMENT);
      expect(res.body.paymentDetails.payableAmount).toBeCloseTo(inputData.amount * (1 + SERVICE_CHARGE_PERCENTAGE));

      const dbSnapshot = await admin.database().ref(`moneyOrders/${res.body.moneyOrder.moneyOrderId}`).once('value');
      expect(dbSnapshot.exists()).toBe(true);
      expect(dbSnapshot.val().amount).toEqual(inputData.amount);
      const userHistorySnapshot = await admin.database().ref(`users/${regularUserData.uid}/paymentHistoryRefs/moneyOrders/${res.body.moneyOrder.moneyOrderId}`).once('value');
      expect(userHistorySnapshot.exists()).toBe(true);
    });

    it('should return 400 for invalid money order data', async () => {
      const res = await request(app)
        .post('/api/money-orders/initiate')
        .set('Authorization', `Bearer ${REGULAR_USER_TOKEN}`)
        .send({ amount: -100 }); // Invalid amount
      expect(res.statusCode).toEqual(400);
    });

    it('should return 401 if no token is provided', async () => {
        const res = await request(app)
          .post('/api/money-orders/initiate')
          .send(createMoneyOrderInputData());
        expect(res.statusCode).toEqual(401);
      });
  });

  // --- POST /api/money-orders/:moneyOrderId/confirm-payment (User) ---
  describe('POST /api/money-orders/:moneyOrderId/confirm-payment', () => {
    it('should allow a user to confirm payment for a money order', async () => {
      const paymentData = {
        transactionId: "txn_123abc",
        paymentGatewayResponse: { details: "success" },
        status: MONEY_ORDER_STATUS.PROCESSING, // Or COMPLETED depending on flow
      };
      const res = await request(app)
        .post(`/api/money-orders/${sampleMoneyOrder1.moneyOrderId}/confirm-payment`)
        .set('Authorization', `Bearer ${REGULAR_USER_TOKEN}`)
        .send(paymentData);

      expect(res.statusCode).toEqual(200);
      expect(res.body.status).toEqual(paymentData.status);
      expect(res.body.transactionId).toEqual(paymentData.transactionId);

      const dbSnapshot = await admin.database().ref(`moneyOrders/${sampleMoneyOrder1.moneyOrderId}`).once('value');
      expect(dbSnapshot.val().status).toEqual(paymentData.status);
    });

    it('should return 404 if money order not found', async () => {
        const res = await request(app)
          .post('/api/money-orders/nonexistent-mo-id/confirm-payment')
          .set('Authorization', `Bearer ${REGULAR_USER_TOKEN}`)
          .send({ transactionId: "txn_fake", paymentGatewayResponse: {}, status: MONEY_ORDER_STATUS.COMPLETED });
        expect(res.statusCode).toEqual(404);
    });

    it('should return 400 if money order is not in PENDING_PAYMENT state', async () => {
        // First, update the status to something else
        await admin.database().ref(`moneyOrders/${sampleMoneyOrder1.moneyOrderId}`).update({ status: MONEY_ORDER_STATUS.COMPLETED });
        const res = await request(app)
          .post(`/api/money-orders/${sampleMoneyOrder1.moneyOrderId}/confirm-payment`)
          .set('Authorization', `Bearer ${REGULAR_USER_TOKEN}`)
          .send({ transactionId: "txn_late", paymentGatewayResponse: {}, status: MONEY_ORDER_STATUS.COMPLETED });
        expect(res.statusCode).toEqual(400);
        expect(res.body.message).toContain('Money order is already completed.');
    });
  });

  // --- GET /api/money-orders/my-orders (User) ---
  describe('GET /api/money-orders/my-orders', () => {
    it('should get money orders for the authenticated user', async () => {
      // sampleMoneyOrder1 was created by regularUserData
      const res = await request(app)
        .get('/api/money-orders/my-orders')
        .set('Authorization', `Bearer ${REGULAR_USER_TOKEN}`);

      expect(res.statusCode).toEqual(200);
      expect(Array.isArray(res.body)).toBe(true);
      expect(res.body.length).toBe(1);
      expect(res.body[0].moneyOrderId).toEqual(sampleMoneyOrder1.moneyOrderId);
    });

    it('should return an empty array if user has no money orders', async () => {
        // Authenticate as admin who has no MOs in this setup
        const res = await request(app)
          .get('/api/money-orders/my-orders')
          .set('Authorization', `Bearer ${ADMIN_USER_TOKEN}`);
        expect(res.statusCode).toEqual(200);
        expect(Array.isArray(res.body)).toBe(true);
        expect(res.body.length).toBe(0);
    });
  });

  // --- GET /api/money-orders/:moneyOrderId (User/Admin) ---
  describe('GET /api/money-orders/:moneyOrderId', () => {
    it('should get money order details for the sender', async () => {
      const res = await request(app)
        .get(`/api/money-orders/${sampleMoneyOrder1.moneyOrderId}`)
        .set('Authorization', `Bearer ${REGULAR_USER_TOKEN}`);
      expect(res.statusCode).toEqual(200);
      expect(res.body.moneyOrderId).toEqual(sampleMoneyOrder1.moneyOrderId);
    });

    it('should get money order details for an admin', async () => {
        const res = await request(app)
          .get(`/api/money-orders/${sampleMoneyOrder1.moneyOrderId}`)
          .set('Authorization', `Bearer ${ADMIN_USER_TOKEN}`);
        expect(res.statusCode).toEqual(200);
        expect(res.body.moneyOrderId).toEqual(sampleMoneyOrder1.moneyOrderId);
    });

    it('should return 403 if a different user tries to access the money order', async () => {
        const anotherUserSuffix = Math.random().toString(36).substring(2, 9);
        const anotherUserData = { uid: `another-user-${anotherUserSuffix}`, email: `another-${anotherUserSuffix}@example.com`, role: USER_ROLES.USER };
        await admin.database().ref(`users/${anotherUserData.uid}`).set(anotherUserData);
        const ANOTHER_USER_TOKEN = 'mock-token-another-user';
        admin.auth().verifyIdToken.mockImplementation(async (token) => { // Extend mock
            if (token === ANOTHER_USER_TOKEN) return { uid: anotherUserData.uid, email: anotherUserData.email };
            if (token === REGULAR_USER_TOKEN) return { uid: regularUserData.uid, email: regularUserData.email };
            if (token === ADMIN_USER_TOKEN) return { uid: adminUserData.uid, email: adminUserData.email };
            throw new Error("unmocked token in GET /:id");
        });

        const res = await request(app)
          .get(`/api/money-orders/${sampleMoneyOrder1.moneyOrderId}`)
          .set('Authorization', `Bearer ${ANOTHER_USER_TOKEN}`);
        expect(res.statusCode).toEqual(403);
    });

    it('should return 404 if money order not found', async () => {
        const res = await request(app)
          .get('/api/money-orders/nonexistent-mo-id-details')
          .set('Authorization', `Bearer ${REGULAR_USER_TOKEN}`);
        expect(res.statusCode).toEqual(404);
    });
  });

  // --- GET /api/money-orders/admin/all (Admin) ---
  describe('GET /api/money-orders/admin/all', () => {
    it('should allow an admin to get all money orders', async () => {
      const res = await request(app)
        .get('/api/money-orders/admin/all')
        .set('Authorization', `Bearer ${ADMIN_USER_TOKEN}`);

      expect(res.statusCode).toEqual(200);
      expect(res.body).toHaveProperty('data');
      expect(Array.isArray(res.body.data)).toBe(true);
      expect(res.body.data.length).toBeGreaterThanOrEqual(1); // At least sampleMoneyOrder1
      expect(res.body.data.find(mo => mo.moneyOrderId === sampleMoneyOrder1.moneyOrderId)).toBeDefined();
    });

    it('should allow admin to filter money orders by status', async () => {
        await admin.database().ref(`moneyOrders/${sampleMoneyOrder1.moneyOrderId}`).update({ status: MONEY_ORDER_STATUS.COMPLETED });
        const inputData2 = createMoneyOrderInputData();
        const moRef2 = admin.database().ref('moneyOrders').push();
        await moRef2.set({ ...inputData2, moneyOrderId: moRef2.key, senderUserId: adminUserData.uid, status: MONEY_ORDER_STATUS.PROCESSING });


        const res = await request(app)
          .get(`/api/money-orders/admin/all?status=${MONEY_ORDER_STATUS.COMPLETED}`)
          .set('Authorization', `Bearer ${ADMIN_USER_TOKEN}`);
        
        expect(res.statusCode).toEqual(200);
        expect(res.body.data.length).toBe(1);
        expect(res.body.data[0].status).toEqual(MONEY_ORDER_STATUS.COMPLETED);
        expect(res.body.data[0].moneyOrderId).toEqual(sampleMoneyOrder1.moneyOrderId);
    });

    it('should return 403 if non-admin tries to get all money orders', async () => {
        const res = await request(app)
          .get('/api/money-orders/admin/all')
          .set('Authorization', `Bearer ${REGULAR_USER_TOKEN}`);
        expect(res.statusCode).toEqual(403);
    });
  });

  // --- PUT /api/money-orders/admin/:moneyOrderId/status (Admin) ---
  describe('PUT /api/money-orders/admin/:moneyOrderId/status', () => {
    it('should allow an admin to update money order status', async () => {
      const newStatus = MONEY_ORDER_STATUS.COMPLETED;
      const res = await request(app)
        .put(`/api/money-orders/admin/${sampleMoneyOrder1.moneyOrderId}/status`)
        .set('Authorization', `Bearer ${ADMIN_USER_TOKEN}`)
        .send({ status: newStatus });

      expect(res.statusCode).toEqual(200);
      expect(res.body.status).toEqual(newStatus);

      const dbSnapshot = await admin.database().ref(`moneyOrders/${sampleMoneyOrder1.moneyOrderId}`).once('value');
      expect(dbSnapshot.val().status).toEqual(newStatus);
    });

    it('should return 404 if admin tries to update status of non-existent money order', async () => {
        const res = await request(app)
          .put('/api/money-orders/admin/nonexistent-mo-id-status/status')
          .set('Authorization', `Bearer ${ADMIN_USER_TOKEN}`)
          .send({ status: MONEY_ORDER_STATUS.CANCELLED });
        expect(res.statusCode).toEqual(404);
    });
    
    it('should return 400 if admin provides invalid status', async () => {
        const res = await request(app)
          .put(`/api/money-orders/admin/${sampleMoneyOrder1.moneyOrderId}/status`)
          .set('Authorization', `Bearer ${ADMIN_USER_TOKEN}`)
          .send({ status: "INVALID_STATUS_HERE" });
        expect(res.statusCode).toEqual(400);
    });

    it('should return 403 if non-admin tries to update status', async () => {
        const res = await request(app)
          .put(`/api/money-orders/admin/${sampleMoneyOrder1.moneyOrderId}/status`)
          .set('Authorization', `Bearer ${REGULAR_USER_TOKEN}`)
          .send({ status: MONEY_ORDER_STATUS.FAILED });
        expect(res.statusCode).toEqual(403);
    });
  });
});