const express = require('express');
const officerController = require('../controllers/officerController');
const { verifyFirebaseToken, fetchUserProfileAndAttach } = require('../middlewares/authMiddleware');
const { isAdmin } = require('../middlewares/roleMiddleware');
const { validateRequestBody } = require('../middlewares/validationMiddleware');
const { officerSchema, updateOfficerSchema } = require('../validators/officerValidators');

const router = express.Router();

router.post(
  '/',
  verifyFirebaseToken,
  fetchUserProfileAndAttach,
  isAdmin,
  validateRequestBody(officerSchema),
  officerController.createOfficer
);

router.get(
  '/:officerId',
  officerController.getOfficerById
);

router.get(
  '/by-post-office/:postOfficeId',
  officerController.getOfficersByPostOffice
);

router.get(
  '/',
  officerController.getAllOfficers 
);

router.put(
  '/:officerId',
  verifyFirebaseToken,
  fetchUserProfileAndAttach,
  isAdmin,
  validateRequestBody(updateOfficerSchema),
  officerController.updateOfficer
);

router.delete(
  '/:officerId',
  verifyFirebaseToken,
  fetchUserProfileAndAttach,
  isAdmin,
  officerController.deleteOfficer
);

module.exports = router;
