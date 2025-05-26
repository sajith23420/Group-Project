const express = require('express');
const bookingController = require('../controllers/bookingController');
const { verifyFirebaseToken, fetchUserProfileAndAttach } = require('../middlewares/authMiddleware');
const { isAdmin, isUser } = require('../middlewares/roleMiddleware');
const { validateRequestBody } = require('../middlewares/validationMiddleware');
const { 
  createBookingSchema, 
  confirmBookingPaymentSchema,
  adminUpdateBookingStatusSchema
} = require('../validators/bookingValidators');

const router = express.Router();

router.post(
  '/',
  verifyFirebaseToken,
  fetchUserProfileAndAttach,
  isUser,
  validateRequestBody(createBookingSchema),
  bookingController.createBooking
);

router.post(
  '/:bookingId/confirm-payment',
  verifyFirebaseToken,
  fetchUserProfileAndAttach,
  isUser,
  validateRequestBody(confirmBookingPaymentSchema),
  bookingController.confirmBookingPayment
);

router.get(
  '/my-bookings',
  verifyFirebaseToken,
  fetchUserProfileAndAttach,
  isUser,
  bookingController.getUserBookings
);

router.get(
  '/:bookingId',
  verifyFirebaseToken,
  fetchUserProfileAndAttach,
  isUser,
  bookingController.getBookingDetails
);

router.put(
  '/:bookingId/cancel',
  verifyFirebaseToken,
  fetchUserProfileAndAttach,
  isUser,
  bookingController.cancelBooking
);

router.get(
  '/admin/all',
  verifyFirebaseToken,
  fetchUserProfileAndAttach,
  isAdmin,
  bookingController.adminGetAllBookings
);

router.put(
  '/admin/:bookingId/status',
  verifyFirebaseToken,
  fetchUserProfileAndAttach,
  isAdmin,
  validateRequestBody(adminUpdateBookingStatusSchema),
  bookingController.adminUpdateBookingStatus
);

module.exports = router;
