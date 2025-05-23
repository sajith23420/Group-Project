const express = require('express');
const mailController = require('../controllers/mailController');
const { verifyFirebaseToken, fetchUserProfileAndAttach } = require('../middlewares/authMiddleware');
const { isAdmin, isUser } = require('../middlewares/roleMiddleware');
const { validateRequestBody } = require('../middlewares/validationMiddleware');
const { 
  createMailSchema, 
  adminUpdateMailStatusSchema 
} = require('../validators/mailValidators');

const router = express.Router();

// Admin: Create mail/parcel
router.post(
  '/',
  verifyFirebaseToken,
  fetchUserProfileAndAttach,
  isAdmin,
  validateRequestBody(createMailSchema),
  mailController.createMail
);

// User: Get own mails/parcels
router.get(
  '/my-mails',
  verifyFirebaseToken,
  fetchUserProfileAndAttach,
  isUser,
  mailController.getUserMails
);

// Admin: Update mail/parcel status
router.put(
  '/admin/:mailId/status',
  verifyFirebaseToken,
  fetchUserProfileAndAttach,
  isAdmin,
  validateRequestBody(adminUpdateMailStatusSchema),
  mailController.adminUpdateMailStatus
);

// Admin: Get all mails/parcels
router.get(
  '/admin/all',
  verifyFirebaseToken,
  fetchUserProfileAndAttach,
  isAdmin,
  mailController.adminGetAllMails
);

module.exports = router;