const express = require('express');
const moneyOrderController = require('../controllers/moneyOrderController');
const { verifyFirebaseToken, fetchUserProfileAndAttach } = require('../middlewares/authMiddleware');
const { isAdmin, isUser } = require('../middlewares/roleMiddleware');
const { validateRequestBody } = require('../middlewares/validationMiddleware');
const { 
  initiateMoneyOrderSchema, 
  confirmMoneyOrderPaymentSchema,
  adminUpdateMoneyOrderStatusSchema 
} = require('../validators/moneyOrderValidators');

const router = express.Router();

router.post(
  '/initiate',
  verifyFirebaseToken,
  fetchUserProfileAndAttach,
  isUser,
  validateRequestBody(initiateMoneyOrderSchema),
  moneyOrderController.initiateMoneyOrder
);

router.post(
  '/:moneyOrderId/confirm-payment',
  verifyFirebaseToken,
  fetchUserProfileAndAttach,
  isUser, 
  validateRequestBody(confirmMoneyOrderPaymentSchema),
  moneyOrderController.confirmMoneyOrderPayment
);

router.get(
  '/my-orders',
  verifyFirebaseToken,
  fetchUserProfileAndAttach,
  isUser,
  moneyOrderController.getUserMoneyOrders
);

router.get(
  '/:moneyOrderId',
  verifyFirebaseToken,
  fetchUserProfileAndAttach,
  isUser, 
  moneyOrderController.getMoneyOrderDetails
);

router.get(
  '/admin/all',
  verifyFirebaseToken,
  fetchUserProfileAndAttach,
  isAdmin,
  moneyOrderController.adminGetAllMoneyOrders
);

router.put(
  '/admin/:moneyOrderId/status',
  verifyFirebaseToken,
  fetchUserProfileAndAttach,
  isAdmin,
  validateRequestBody(adminUpdateMoneyOrderStatusSchema),
  moneyOrderController.adminUpdateMoneyOrderStatus
);

module.exports = router;
