const admin = require('../config/firebaseAdmin');
const { USER_ROLES } = require('../config/constants');
const User = require('../models/userModel');


const verifyFirebaseToken = async (req, res, next) => {
  const authHeader = req.headers.authorization;

  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return res.status(401).send({ error: 'Unauthorized. No token provided or invalid format.' });
  }

  const idToken = authHeader.split('Bearer ')[1];

  try {
    const decodedToken = await admin.auth().verifyIdToken(idToken);
    req.user = decodedToken;
    next();
  } catch (error) {
    console.error('Error verifying Firebase ID token:', error);
    if (error.code === 'auth/id-token-expired') {
      return res.status(401).send({ error: 'Unauthorized. Token expired.' });
    }
    return res.status(403).send({ error: 'Forbidden. Invalid token.' });
  }
};

const fetchUserProfileAndAttach = async (req, res, next) => {
  if (!req.user || !req.user.uid) {
    return res.status(401).send({ error: 'Unauthorized. User not authenticated.' });
  }

  try {
    const userRef = admin.database().ref(`users/${req.user.uid}`);
    const snapshot = await userRef.once('value');
    const userProfile = snapshot.val();

    if (!userProfile) {
      // User profile not found in database, create a basic user
      try {
        const { uid, email, displayName, picture } = req.user; // Extract info from decoded token
        const newUserProfile = new User(
          uid,
          email,
          displayName || 'New User',
          null, // phoneNumber
          USER_ROLES.USER,
          picture || null //profilePictureUrl, take it from picture of firebase auth
        );

        const userRef = admin.database().ref(`users/${uid}`);
        await userRef.set(newUserProfile.toFirestore());

        req.dbUser = newUserProfile; // Attach the newly created user to the request
        console.log(`User profile created and attached to request for UID: ${req.user.uid}`);
        next();
      } catch (creationError) {
        console.error('Error creating user profile in database:', creationError);
        return res.status(500).send({ error: 'Internal server error creating user profile.' });
      }
    } else {
      req.dbUser = userProfile; // Attach the existing user to the request
      next();
    }
  } catch (error) {
    console.error('Error fetching user profile from database:', error);
    return res.status(500).send({ error: 'Internal server error fetching user profile.' });
  }
};


module.exports = {
  verifyFirebaseToken,
  fetchUserProfileAndAttach,
};
