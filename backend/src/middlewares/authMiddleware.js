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
    const rawUserProfile = snapshot.val();

    if (!rawUserProfile) {
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

        // const userRef = admin.database().ref(`users/${uid}`); // Already have userRef
        await userRef.set(newUserProfile.toFirestore());

        req.dbUser = newUserProfile; // Attach the newly created user to the request
        console.log(`User profile created and attached to request for UID: ${req.user.uid}`);
        next();
      } catch (creationError) {
        console.error('Error creating user profile in database:', creationError);
        return res.status(500).send({ error: 'Internal server error creating user profile.' });
      }
    } else {
      // User profile exists in DB, process it
      let processedUserProfile = null;
      if (Array.isArray(rawUserProfile)) {
        if (rawUserProfile.length > 0 && typeof rawUserProfile[0] === 'object' && rawUserProfile[0] !== null) {
          console.warn(`User profile for UID ${req.user.uid} from DB was an array, taking first element.`);
          processedUserProfile = rawUserProfile[0];
        } else {
          console.warn(`User profile for UID ${req.user.uid} from DB was an array but not in expected [object] format: ${JSON.stringify(rawUserProfile)}. Treating as malformed.`);
          // processedUserProfile remains null
        }
      } else if (typeof rawUserProfile === 'object' && rawUserProfile !== null) {
        processedUserProfile = rawUserProfile; // It's already a good object
      } else {
        console.warn(`User profile for UID ${req.user.uid} from DB was of unexpected type: ${typeof rawUserProfile}. Treating as malformed.`);
        // processedUserProfile remains null
      }

      if (processedUserProfile) {
        req.dbUser = processedUserProfile; // Attach the existing (and processed) user to the request
        next();
      } else {
        // Malformed existing profile.
        console.error(`Malformed user profile in DB for UID ${req.user.uid}. Data: ${JSON.stringify(rawUserProfile)}`);
        return res.status(500).send({ error: 'User profile data in DB is malformed.' });
      }
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
