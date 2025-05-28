const admin = require('../config/firebaseAdmin');
const User = require('../models/userModel');
const { USER_ROLES } = require('../config/constants');
const path = require('path'); // Import path module
const fs = require('fs'); // Import fs module
const { v4: uuidv4 } = require('uuid'); // For unique filenames

const UPLOAD_BASE_URL = '/uploads'; // Or read from config if dynamic
const USER_PROFILE_PICTURES_DIR = path.join(__dirname, '..', '..', 'uploads', 'user_profile_pictures');


const onUserCreate = async (userRecord) => {
  const { uid, email, displayName, photoURL } = userRecord;

  // Corrected User constructor call to match its definition:
  // constructor(uid, email, displayName, phoneNumber, role, profilePictureUrl = null, paymentHistoryRefs = [])
  const newUserProfile = new User(
    uid,
    email,
    displayName || 'New User',
    null, // phoneNumber - Firebase Auth record might not have this directly, or set if available
    USER_ROLES.USER,
    photoURL // This will be assigned to profilePictureUrl
  );

  try {
    const userRef = admin.database().ref(`users/${uid}`);
    await userRef.set(newUserProfile.toFirestore());
    console.log(`User profile created in DB for UID: ${uid} with photoURL (as profilePictureUrl): ${photoURL}`);
    return newUserProfile;
  } catch (error) {
    console.error(`Error creating user profile in DB for UID ${uid}:`, error);
    throw error;
  }
};

const uploadUserProfilePicture = async (req, res, next) => {
  try {
    const { uid } = req.user;
    if (!req.file) {
      return res.status(400).json({ message: 'No file uploaded.' });
    }

    const userUploadDir = path.join(USER_PROFILE_PICTURES_DIR, uid);
    if (!fs.existsSync(userUploadDir)) {
      fs.mkdirSync(userUploadDir, { recursive: true });
    }

    const fileExtension = path.extname(req.file.originalname);
    const uniqueFileName = `profile_${uuidv4()}${fileExtension}`;
    const localFilePath = path.join(userUploadDir, uniqueFileName);
    const publicUrl = `${UPLOAD_BASE_URL}/user_profile_pictures/${uid}/${uniqueFileName}`;

    try {
      await fs.promises.writeFile(localFilePath, req.file.buffer);

      const userRef = admin.database().ref(`users/${uid}`);
      // Optionally, delete old profile picture if it exists and is a local file
      const userSnapshot = await userRef.once('value');
      const userData = userSnapshot.val();
      if (userData && userData.profilePictureUrl && userData.profilePictureUrl.startsWith(UPLOAD_BASE_URL)) {
        const oldFilePath = path.join(__dirname, '..', '..', userData.profilePictureUrl.replace(UPLOAD_BASE_URL, 'uploads'));
        if (fs.existsSync(oldFilePath)) {
          try {
            fs.unlinkSync(oldFilePath);
            console.log(`Deleted old profile picture: ${oldFilePath}`);
          } catch (unlinkErr) {
            console.error(`Error deleting old profile picture ${oldFilePath}:`, unlinkErr);
          }
        }
      }

      await userRef.update({
        profilePictureUrl: publicUrl,
        updatedAt: new Date().toISOString(),
      });

      const updatedSnapshot = await userRef.once('value');
      res.status(200).json({
        message: 'Profile picture uploaded successfully.',
        profilePictureUrl: publicUrl,
        userProfile: updatedSnapshot.val(),
      });
    } catch (err) {
      console.error('Error saving file locally or updating DB:', err);
      return next(err);
    }
  } catch (error) {
    next(error);
  }
};

const getUserProfile = async (req, res, next) => {
  try {
    if (!req.dbUser) {
      return res.status(404).json({ message: 'User profile not available on request object.' });
    }

    const { uid } = req.user;
    const firebaseUser = await admin.auth().getUser(uid);
    const photoURL = firebaseUser.photoURL;
    const displayName = firebaseUser.displayName || req.dbUser.displayName || 'User';
    const email = firebaseUser.email || req.dbUser.email || '';
    const userRef = admin.database().ref(`users/${uid}`);
    // Sync profilePictureUrl if needed
    if (photoURL && req.dbUser.profilePictureUrl !== photoURL) {
      await userRef.update({ profilePictureUrl: photoURL });
      req.dbUser.profilePictureUrl = photoURL;
    }
    // Always return displayName, email, and profilePictureUrl
    const userProfile = {
      ...req.dbUser,
      displayName,
      email,
      profilePictureUrl: req.dbUser.profilePictureUrl || photoURL || null,
    };
    res.status(200).json(userProfile);
  } catch (error) {
    next(error);
  }
};

const updateUserProfile = async (req, res, next) => {
  const { uid } = req.user;
  const { displayName, phoneNumber, email, address } = req.validatedBody;

  try {
    const userRef = admin.database().ref(`users/${uid}`);
    const snapshot = await userRef.once('value'); // First DB call
    if (!snapshot.exists()) {
      return res.status(404).json({ message: 'User profile not found.' });
    }

    const updates = {};
    if (displayName !== undefined) updates.displayName = displayName;
    if (phoneNumber !== undefined) updates.phoneNumber = phoneNumber;
    if (email !== undefined) updates.email = email;
    if (address !== undefined) updates.address = address;
    updates.updatedAt = new Date().toISOString();

    await userRef.update(updates);
    const updatedSnapshot = await userRef.once('value');
    res.status(200).json(updatedSnapshot.val());
  } catch (error) {
    next(error);
  }
};

const adminUpdateUserRole = async (req, res, next) => {
  const { userIdToUpdate } = req.params;
  const { role } = req.validatedBody;

  try {
    const userRef = admin.database().ref(`users/${userIdToUpdate}`);
    const snapshot = await userRef.once('value'); // First DB call

    if (!snapshot.exists()) {
      return res.status(404).json({ message: `User with ID ${userIdToUpdate} not found.` });
    }

    await userRef.update({ role: role, updatedAt: new Date().toISOString() });
    const updatedSnapshot = await userRef.once('value'); // Second DB call
    res.status(200).json(updatedSnapshot.val());
  } catch (error) {
    next(error);
  }
};

const adminGetAllUsers = async (req, res, next) => {
  try {
    const usersRef = admin.database().ref('users');
    const snapshot = await usersRef.once('value');
    const users = snapshot.val();
    if (!users) {
      return res.status(200).json([]);
    }
    // Convert the users object to an array of user objects
    const usersArray = Object.keys(users).map(key => ({ id: key, ...users[key] }));
    res.status(200).json(usersArray);
  } catch (error) {
    next(error);
  }
};

module.exports = {
  onUserCreate,
  getUserProfile,
  updateUserProfile,
  adminUpdateUserRole,
  adminGetAllUsers,
  uploadUserProfilePicture,
};