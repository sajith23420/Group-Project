// __tests__/routes/booking.test.js

const request = require('supertest');
const app = require('../../app');
const admin = require('../../src/config/firebaseAdmin'); // REAL admin object
const { USER_ROLES, BOOKING_STATUS, POST_OFFICE_SERVICES } = require('../../src/config/constants');
const Resort = require('../../src/models/resortModel'); // For resort setup
const Booking = require('../../src/models/bookingModel'); // For data structure reference

// Helper to create resort data (minimal for booking tests)
async function createSampleResortForBooking(idPrefix = 'resort-bk', overrides = {}) {
  const randomSuffix = Math.random().toString(36).substring(2, 7);
  const resortId = `${idPrefix}-${randomSuffix}`;
  const resortData = {
    resortId: resortId,
    name: `Test Resort for Booking ${randomSuffix}`,
    location: `Test Location ${randomSuffix}`,
    description: "A lovely test resort.",
    amenities: ["Pool"],
    capacityPerUnit: overrides.capacityPerUnit || 2,
    numberOfUnits: overrides.numberOfUnits || 5,
    pricePerNightPerUnit: overrides.pricePerNightPerUnit || 100.00,
    images: [],
    contactInfo: "123-456-7890",
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString(),
    ...overrides
  };
  await admin.database().ref(`resorts/${resortId}`).set(resortData);
  return resortData;
}

// Helper for booking input data
function createBookingInputData(resortId, overrides = {}) {
    const checkIn = new Date();
    checkIn.setDate(checkIn.getDate() + 7); // Book a week from now
    const checkOut = new Date(checkIn);
    checkOut.setDate(checkOut.getDate() + 2); // For 2 nights

    return {
        resortId: resortId,
        checkInDate: checkIn.toISOString().split('T')[0], // YYYY-MM-DD
        checkOutDate: checkOut.toISOString().split('T')[0], // YYYY-MM-DD
        numberOfGuests: 2,
        numberOfUnitsBooked: 1,
        specialRequests: "Late check-in preferred.",
        ...overrides,
    };
}


describe('Booking Routes', () => {
  let regularUserData;
  let adminUserData;
  let testResort1;
  let sampleBooking1; // To store a created booking for later tests

  const REGULAR_USER_TOKEN = 'mock-token-booking-user';
  const ADMIN_USER_TOKEN = 'mock-token-booking-admin';

  beforeEach(async () => {
    if (!admin.auth() || typeof admin.auth().verifyIdToken !== 'function') {
        if (admin.auth()) { admin.auth().verifyIdToken = jest.fn(); }
        else { admin.auth = jest.fn().mockReturnValue({ verifyIdToken: jest.fn() }); }
    }
    admin.auth().verifyIdToken.mockImplementation(async (token) => {
      if (token === REGULAR_USER_TOKEN) return { uid: regularUserData.uid, email: regularUserData.email };
      if (token === ADMIN_USER_TOKEN) return { uid: adminUserData.uid, email: adminUserData.email };
      const error = new Error('Mock verifyIdToken: Invalid token for booking tests');
      error.code = 'auth/argument-error';
      throw error;
    });

    const userSuffix = Math.random().toString(36).substring(2, 9);
    regularUserData = { uid: `reguser-bk-${userSuffix}`, email: `reguser-bk-${userSuffix}@example.com`, role: USER_ROLES.USER, displayName: 'Booking Test User' };
    adminUserData = { uid: `admin-bk-${userSuffix}`, email: `admin-bk-${userSuffix}@example.com`, role: USER_ROLES.ADMIN, displayName: 'Booking Test Admin' };

    await admin.database().ref('users').set(null);
    await admin.database().ref('resorts').set(null);
    await admin.database().ref('bookings').set(null);

    await admin.database().ref(`users/${regularUserData.uid}`).set(regularUserData);
    await admin.database().ref(`users/${adminUserData.uid}`).set(adminUserData);

    testResort1 = await createSampleResortForBooking('bk-resort1', { numberOfUnits: 3, pricePerNightPerUnit: 120 });

    // Create a sample booking for regularUserData
    const bookingInput1 = createBookingInputData(testResort1.resortId);
    const bookingRef1 = admin.database().ref('bookings').push();
    const totalAmount1 = 2 * testResort1.pricePerNightPerUnit * bookingInput1.numberOfUnitsBooked; // 2 nights
    sampleBooking1 = {
        bookingId: bookingRef1.key,
        userId: regularUserData.uid,
        ...bookingInput1,
        totalAmount: totalAmount1,
        status: BOOKING_STATUS.PENDING_PAYMENT,
        bookedAt: new Date().toISOString(),
        updatedAt: new Date().toISOString(),
    };
    await bookingRef1.set(sampleBooking1);
    await admin.database().ref(`users/${regularUserData.uid}/paymentHistoryRefs/bookings/${bookingRef1.key}`).set(true);

  });

  // --- POST /api/bookings/ (Create Booking - User) ---
  describe('POST /api/bookings/', () => {
    it('should allow a user to create a booking', async () => {
      const bookingInput = createBookingInputData(testResort1.resortId, { numberOfUnitsBooked: 1 });
      const res = await request(app)
        .post('/api/bookings')
        .set('Authorization', `Bearer ${REGULAR_USER_TOKEN}`)
        .send(bookingInput);

      expect(res.statusCode).toEqual(201);
      expect(res.body).toHaveProperty('booking');
      const createdBooking = res.body.booking;
      expect(createdBooking.userId).toEqual(regularUserData.uid);
      expect(createdBooking.resortId).toEqual(testResort1.resortId);
      expect(createdBooking.status).toEqual(BOOKING_STATUS.PENDING_PAYMENT);
      expect(createdBooking.totalAmount).toBe(2 * testResort1.pricePerNightPerUnit * bookingInput.numberOfUnitsBooked); // For 2 nights

      const dbSnapshot = await admin.database().ref(`bookings/${createdBooking.bookingId}`).once('value');
      expect(dbSnapshot.exists()).toBe(true);
    });

    it('should return 400 if resort not found', async () => {
        const bookingInput = createBookingInputData("nonexistent-resort-id");
        const res = await request(app)
            .post('/api/bookings')
            .set('Authorization', `Bearer ${REGULAR_USER_TOKEN}`)
            .send(bookingInput);
        expect(res.statusCode).toEqual(404);
        expect(res.body.message).toEqual('Resort not found.');
    });
    
    it('should return 400 if not enough units available', async () => {
        const bookingInput = createBookingInputData(testResort1.resortId, { numberOfUnitsBooked: testResort1.numberOfUnits + 1 }); // Request more than available
        const res = await request(app)
            .post('/api/bookings')
            .set('Authorization', `Bearer ${REGULAR_USER_TOKEN}`)
            .send(bookingInput);
        expect(res.statusCode).toEqual(400);
        expect(res.body.message).toContain('Not enough units available');
    });
    // Add more validation tests (dates, guests, etc.)
  });

  // --- POST /api/bookings/:bookingId/confirm-payment (User) ---
  describe('POST /api/bookings/:bookingId/confirm-payment', () => {
    it('should allow a user to confirm payment for a booking', async () => {
      const paymentData = {
        transactionId: "txn_bk_789xyz",
        paymentGatewayResponse: { details: "booking payment success" }
      };
      const res = await request(app)
        .post(`/api/bookings/${sampleBooking1.bookingId}/confirm-payment`)
        .set('Authorization', `Bearer ${REGULAR_USER_TOKEN}`)
        .send(paymentData);

      expect(res.statusCode).toEqual(200);
      expect(res.body.status).toEqual(BOOKING_STATUS.CONFIRMED);
      expect(res.body.transactionId).toEqual(paymentData.transactionId);

      const dbSnapshot = await admin.database().ref(`bookings/${sampleBooking1.bookingId}`).once('value');
      expect(dbSnapshot.val().status).toEqual(BOOKING_STATUS.CONFIRMED);
    });
    // Add tests for 404, booking not in PENDING_PAYMENT state
  });

  // --- GET /api/bookings/my-bookings (User) ---
  describe('GET /api/bookings/my-bookings', () => {
    it('should get bookings for the authenticated user', async () => {
      const res = await request(app)
        .get('/api/bookings/my-bookings')
        .set('Authorization', `Bearer ${REGULAR_USER_TOKEN}`);

      expect(res.statusCode).toEqual(200);
      expect(Array.isArray(res.body)).toBe(true);
      expect(res.body.length).toBe(1);
      expect(res.body[0].bookingId).toEqual(sampleBooking1.bookingId);
    });
  });

  // --- GET /api/bookings/:bookingId (User/Admin) ---
  describe('GET /api/bookings/:bookingId', () => {
    it('should get booking details for the owner', async () => {
      const res = await request(app)
        .get(`/api/bookings/${sampleBooking1.bookingId}`)
        .set('Authorization', `Bearer ${REGULAR_USER_TOKEN}`);
      expect(res.statusCode).toEqual(200);
      expect(res.body.bookingId).toEqual(sampleBooking1.bookingId);
    });

    it('should get booking details for an admin', async () => {
        const res = await request(app)
          .get(`/api/bookings/${sampleBooking1.bookingId}`)
          .set('Authorization', `Bearer ${ADMIN_USER_TOKEN}`);
        expect(res.statusCode).toEqual(200);
        expect(res.body.bookingId).toEqual(sampleBooking1.bookingId);
    });
    // Add tests for 403 (different user), 404
  });

  // --- PUT /api/bookings/:bookingId/cancel (User) ---
  describe('PUT /api/bookings/:bookingId/cancel', () => {
    it('should allow a user to cancel their booking', async () => {
      // First confirm the booking to test cancellation of a confirmed booking
      await admin.database().ref(`bookings/${sampleBooking1.bookingId}`).update({ status: BOOKING_STATUS.CONFIRMED });
      
      const res = await request(app)
        .put(`/api/bookings/${sampleBooking1.bookingId}/cancel`)
        .set('Authorization', `Bearer ${REGULAR_USER_TOKEN}`);

      expect(res.statusCode).toEqual(200);
      expect(res.body.status).toEqual(BOOKING_STATUS.CANCELLED_BY_USER);

      const dbSnapshot = await admin.database().ref(`bookings/${sampleBooking1.bookingId}`).once('value');
      expect(dbSnapshot.val().status).toEqual(BOOKING_STATUS.CANCELLED_BY_USER);
    });
    // Add tests for 404, 403 (different user), booking not in cancellable state
  });

  // --- GET /api/bookings/admin/all (Admin) ---
  describe('GET /api/bookings/admin/all', () => {
    it('should allow an admin to get all bookings', async () => {
      const res = await request(app)
        .get('/api/bookings/admin/all')
        .set('Authorization', `Bearer ${ADMIN_USER_TOKEN}`);
      expect(res.statusCode).toEqual(200);
      expect(res.body.data.length).toBeGreaterThanOrEqual(1);
    });
    // Add tests for filtering
  });

  // --- PUT /api/bookings/admin/:bookingId/status (Admin) ---
  describe('PUT /api/bookings/admin/:bookingId/status', () => {
    it('should allow an admin to update booking status', async () => {
      const newStatus = BOOKING_STATUS.CANCELLED_BY_ADMIN;
      const res = await request(app)
        .put(`/api/bookings/admin/${sampleBooking1.bookingId}/status`)
        .set('Authorization', `Bearer ${ADMIN_USER_TOKEN}`)
        .send({ status: newStatus });

      expect(res.statusCode).toEqual(200);
      expect(res.body.status).toEqual(newStatus);
      const dbSnapshot = await admin.database().ref(`bookings/${sampleBooking1.bookingId}`).once('value');
      expect(dbSnapshot.val().status).toEqual(newStatus);
    });
    // Add tests for 404, 400 (invalid status), 403
  });
});