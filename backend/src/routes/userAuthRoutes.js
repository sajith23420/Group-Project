const express = require('express');
const userAuthController = require('../controllers/userAuthController');
const { verifyFirebaseToken, fetchUserProfileAndAttach } = require('../middlewares/authMiddleware');
const { isAdmin, isUser } = require('../middlewares/roleMiddleware');
const { validateRequestBody } = require('../middlewares/validationMiddleware');
const { updateUserProfileSchema, adminUpdateUserRoleSchema } = require('../validators/userValidators');
const { profilePictureUpload } = require('../middlewares/uploadMiddleware');

const router = express.Router();

router.get(
  '/profile',
  verifyFirebaseToken,
  fetchUserProfileAndAttach,
  isUser,
  userAuthController.getUserProfile
);

router.put(
  '/profile',
  verifyFirebaseToken,
  fetchUserProfileAndAttach,
  isUser,
  validateRequestBody(updateUserProfileSchema),
  userAuthController.updateUserProfile
);

router.post(
  '/profile/upload-picture',
  verifyFirebaseToken,
  fetchUserProfileAndAttach,
  isUser,
  profilePictureUpload.single('profilePicture'),
  userAuthController.uploadUserProfilePicture
);

router.put(
  '/admin/users/:userIdToUpdate/role',
  verifyFirebaseToken,
  fetchUserProfileAndAttach,
  isAdmin,
  validateRequestBody(adminUpdateUserRoleSchema),
  userAuthController.adminUpdateUserRole
);

router.get(
  '/admin/users',
  verifyFirebaseToken,
  fetchUserProfileAndAttach,
  isAdmin,
  userAuthController.adminGetAllUsers
);

module.exports = router;
