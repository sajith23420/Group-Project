const express = require('express');
const feedbackController = require('../controllers/feedbackController');
const { verifyFirebaseToken, fetchUserProfileAndAttach } = require('../middlewares/authMiddleware');
const { isAdmin, isUser } = require('../middlewares/roleMiddleware');
const { validateRequestBody } = require('../middlewares/validationMiddleware');
const { 
  submitFeedbackSchema, 
  adminUpdateFeedbackStatusSchema 
} = require('../validators/feedbackValidators');

const router = express.Router();

router.post(
  '/',
  verifyFirebaseToken,
  fetchUserProfileAndAttach,
  isUser,
  validateRequestBody(submitFeedbackSchema),
  feedbackController.submitFeedback
);

router.get(
  '/my-feedback',
  verifyFirebaseToken,
  fetchUserProfileAndAttach,
  isUser,
  feedbackController.getUserFeedback
);

router.get(
  '/admin/all',
  verifyFirebaseToken,
  fetchUserProfileAndAttach,
  isAdmin,
  feedbackController.adminGetAllFeedback
);

router.put(
  '/admin/:feedbackId/status',
  verifyFirebaseToken,
  fetchUserProfileAndAttach,
  isAdmin,
  validateRequestBody(adminUpdateFeedbackStatusSchema),
  feedbackController.adminUpdateFeedbackStatus
);

module.exports = router;
