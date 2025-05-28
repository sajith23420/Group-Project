const express = require('express');
const resortController = require('../controllers/resortController');
const { verifyFirebaseToken, fetchUserProfileAndAttach } = require('../middlewares/authMiddleware');
const { isAdmin } = require('../middlewares/roleMiddleware');
const { validateRequestBody } = require('../middlewares/validationMiddleware');
const { 
  resortSchema, 
  updateResortSchema, 
  checkAvailabilitySchema,
  deleteResortImageSchema 
} = require('../validators/resortValidators');
const { resortImageUpload } = require('../middlewares/uploadMiddleware');

const router = express.Router();

router.post(
  '/',
  verifyFirebaseToken,
  fetchUserProfileAndAttach,
  isAdmin,
  validateRequestBody(resortSchema),
  resortController.createResort
);

router.get(
  '/:resortId',
  resortController.getResortById
);

router.get(
  '/',
  resortController.getAllResorts
);

router.put(
  '/:resortId',
  verifyFirebaseToken,
  fetchUserProfileAndAttach,
  isAdmin,
  validateRequestBody(updateResortSchema),
  resortController.updateResort
);

router.delete(
  '/:resortId',
  verifyFirebaseToken,
  fetchUserProfileAndAttach,
  isAdmin,
  resortController.deleteResort
);

router.post(
  '/:resortId/check-availability',
  validateRequestBody(checkAvailabilitySchema),
  resortController.checkResortAvailability
);

router.post(
  '/:resortId/images',
  verifyFirebaseToken,
  fetchUserProfileAndAttach,
  isAdmin,
  resortImageUpload.single('resortImage'),
  resortController.uploadResortImage
);

router.delete(
  '/:resortId/images/delete',
  verifyFirebaseToken,
  fetchUserProfileAndAttach,
  isAdmin,
  validateRequestBody(deleteResortImageSchema),
  resortController.deleteResortImage
);

module.exports = router;