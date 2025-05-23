const express = require('express');
const billPaymentController = require('../controllers/billPaymentController');
const { verifyFirebaseToken, fetchUserProfileAndAttach } = require('../middlewares/authMiddleware');
const { isAdmin, isUser } = require('../middlewares/roleMiddleware');
const { validateRequestBody } = require('../middlewares/validationMiddleware');
const { 
  initiateBillPaymentSchema, 
  confirmBillPaymentSchema 
} = require('../validators/billPaymentValidators');

const router = express.Router();

router.get(
  '/types',
  billPaymentController.getAvailableBillTypes
);

router.post(
  '/initiate',
  verifyFirebaseToken,
  fetchUserProfileAndAttach,
  isUser,
  validateRequestBody(initiateBillPaymentSchema),
  billPaymentController.initiateBillPayment
);

router.post(
  '/:billPaymentId/confirm-payment',
  verifyFirebaseToken,
  fetchUserProfileAndAttach,
  isUser,
  validateRequestBody(confirmBillPaymentSchema),
  billPaymentController.confirmBillPayment
);

router.get(
  '/my-payments',
  verifyFirebaseToken,
  fetchUserProfileAndAttach,
  isUser,
  billPaymentController.getUserBillPayments
);

router.get(
  '/:billPaymentId',
  verifyFirebaseToken,
  fetchUserProfileAndAttach,
  isUser,
  billPaymentController.getBillPaymentDetails
);

router.get(
  '/admin/all',
  verifyFirebaseToken,
  fetchUserProfileAndAttach,
  isAdmin,
  billPaymentController.adminGetAllBillPayments
);

module.exports = router;
