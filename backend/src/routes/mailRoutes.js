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
 
// Get mails/parcels by NIC (userId)
router.get(
  '/by-nic/:nic',
  verifyFirebaseToken, // Assuming this endpoint requires authentication
  fetchUserProfileAndAttach, // Assuming user profile is needed
  mailController.getMailsByNic
);

// Admin: Delete mail/parcel by mailId
router.delete(
  '/:mailId', // Assuming the mailId is passed as a URL parameter
  verifyFirebaseToken,
  fetchUserProfileAndAttach,
  isAdmin, // Only admin should be able to delete
  mailController.deleteMail // Assuming a deleteMail function will be added to the controller
);

module.exports = router;