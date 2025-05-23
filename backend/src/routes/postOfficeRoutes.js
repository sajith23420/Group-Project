const express = require('express');
const postOfficeController = require('../controllers/postOfficeController');
const { verifyFirebaseToken, fetchUserProfileAndAttach } = require('../middlewares/authMiddleware');
const { isAdmin } = require('../middlewares/roleMiddleware');
const { validateRequestBody } = require('../middlewares/validationMiddleware');
const { postOfficeSchema, updatePostOfficeSchema, searchPostOfficeSchema } = require('../validators/postOfficeValidators');

const router = express.Router();

router.post(
  '/',
  verifyFirebaseToken,
  fetchUserProfileAndAttach,
  isAdmin,
  validateRequestBody(postOfficeSchema),
  postOfficeController.createPostOffice
);

router.get(
  '/search',
  postOfficeController.searchPostOffices 
);


router.get(
  '/:postOfficeId',
  postOfficeController.getPostOfficeById
);

router.get(
  '/',
  postOfficeController.getAllPostOffices
);


router.put(
  '/:postOfficeId',
  verifyFirebaseToken,
  fetchUserProfileAndAttach,
  isAdmin,
  validateRequestBody(updatePostOfficeSchema),
  postOfficeController.updatePostOffice
);

router.delete(
  '/:postOfficeId',
  verifyFirebaseToken,
  fetchUserProfileAndAttach,
  isAdmin,
  postOfficeController.deletePostOffice
);


module.exports = router;
