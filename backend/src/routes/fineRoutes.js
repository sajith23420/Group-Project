const express = require('express');
const fineController = require('../controllers/fineController');
const { verifyFirebaseToken, fetchUserProfileAndAttach } = require('../middlewares/authMiddleware');
const { isAdmin, isUser } = require('../middlewares/roleMiddleware');
const { validateRequestBody } = require('../middlewares/validationMiddleware');
const { 
  createFineSchema, 
  adminUpdateFineStatusSchema 
} = require('../validators/fineValidators');

const router = express.Router();

// Admin: Create fine
router.post(
  '/',
  verifyFirebaseToken,
  fetchUserProfileAndAttach,
  isAdmin,
  validateRequestBody(createFineSchema),
  fineController.createFine
);

// User: Mark fine as pay-by-customer
router.put(
  '/:fineId/pay',
  verifyFirebaseToken,
  fetchUserProfileAndAttach,
  isUser,
  fineController.customerPayFine
);

// Admin: Update fine status (confirm/decline/pending)
router.put(
  '/admin/:fineId/status',
  verifyFirebaseToken,
  fetchUserProfileAndAttach,
  isAdmin,
  validateRequestBody(adminUpdateFineStatusSchema),
  fineController.adminUpdateFineStatus
);

// User: Get own fines
router.get(
  '/my-fines',
  verifyFirebaseToken,
  fetchUserProfileAndAttach,
  isUser,
  fineController.getUserFines
);

// Admin: Get all fines
router.get(
  '/admin/all',
  verifyFirebaseToken,
  fetchUserProfileAndAttach,
  isAdmin,
  fineController.adminGetAllFines
);

module.exports = router;