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

    fs.writeFile(localFilePath, req.file.buffer, async (err) => {
      if (err) {
        console.error('Error saving file locally:', err);
        return next(err);
      }

      try {
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
      } catch (error) {
        console.error('Error updating database with local file URL:', error);
        // If DB update fails, try to delete the just-uploaded file
        try {
          fs.unlinkSync(localFilePath);
        } catch (cleanupErr) {
          console.error('Error cleaning up uploaded file after DB error:', cleanupErr);
        }
        return next(error);
      }
    });
  } catch (error) {
    next(error);
  }
};

const getUserProfile = async (req, res, next) => {
  try {
    if (!req.dbUser) {
      // This case should ideally be caught by fetchUserProfileAndAttach sending a 404
      // if the profile isn't found. If it reaches here, it implies req.dbUser was not set
      // possibly due to an issue in fetchUserProfileAndAttach or the preceding auth middleware.
      return res.status(404).json({ message: 'User profile not available on request object.' });
    }
    res.status(200).json(req.dbUser);
  } catch (error) {
    next(error);
  }
};

const updateUserProfile = async (req, res, next) => {
  const { uid } = req.user;
  const { displayName, phoneNumber } = req.validatedBody;

  try {
    const userRef = admin.database().ref(`users/${uid}`);
    const snapshot = await userRef.once('value'); // First DB call
    if (!snapshot.exists()) {
      // This should ideally not be hit if fetchUserProfileAndAttach worked,
      // but good for robustness.
      return res.status(404).json({ message: 'User profile not found.' });
    }

    const updates = {};
    if (displayName !== undefined) updates.displayName = displayName;
    if (phoneNumber !== undefined) updates.phoneNumber = phoneNumber;
    updates.updatedAt = new Date().toISOString();

    await userRef.update(updates);
    const updatedSnapshot = await userRef.once('value'); // Second DB call
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