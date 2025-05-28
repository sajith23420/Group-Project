const admin = require('../config/firebaseAdmin');
const Officer = require('../models/officerModel');

const createOfficer = async (req, res, next) => {
  try {
    const { name, designation, assignedPostOfficeId, contactNumber, email, photoUrl } = req.validatedBody;
    const officersRef = admin.database().ref('officers');
    const newOfficerRef = officersRef.push();
    const officerId = newOfficerRef.key;

    const newOfficer = new Officer(
      officerId,
      name,
      designation,
      assignedPostOfficeId,
      contactNumber,
      email,
      photoUrl
    );

    await newOfficerRef.set(newOfficer.toFirestore());
    res.status(201).json(newOfficer);
  } catch (error) {
    next(error);
  }
};

const getOfficerById = async (req, res, next) => {
  try {
    const { officerId } = req.params;
    const officerRef = admin.database().ref(`officers/${officerId}`);
    const snapshot = await officerRef.once('value');

    if (!snapshot.exists()) {
      return res.status(404).json({ message: 'Officer not found.' });
    }
    res.status(200).json(snapshot.val());
  } catch (error) {
    next(error);
  }
};

const getOfficersByPostOffice = async (req, res, next) => {
  try {
    const { postOfficeId } = req.params;
    const officersRef = admin.database().ref('officers');
    const snapshot = await officersRef.orderByChild('assignedPostOfficeId').equalTo(postOfficeId).once('value');
    
    const officers = [];
    snapshot.forEach(childSnapshot => {
      officers.push({ id: childSnapshot.key, ...childSnapshot.val() });
    });

    if (officers.length === 0) {
      return res.status(404).json({ message: 'No officers found for this post office.' });
    }
    res.status(200).json(officers);
  } catch (error) {
    next(error);
  }
};

const getAllOfficers = async (req, res, next) => {
  try {
    const officersRef = admin.database().ref('officers');
    const snapshot = await officersRef.once('value');
    const officers = [];
    snapshot.forEach(childSnapshot => {
      officers.push({ id: childSnapshot.key, ...childSnapshot.val() });
    });
    res.status(200).json(officers);
  } catch (error) {
    next(error);
  }
};

const updateOfficer = async (req, res, next) => {
  try {
    const { officerId } = req.params;
    const updates = req.validatedBody;

    const officerRef = admin.database().ref(`officers/${officerId}`);
    const snapshot = await officerRef.once('value');

    if (!snapshot.exists()) {
      return res.status(404).json({ message: 'Officer not found.' });
    }

    updates.updatedAt = new Date().toISOString();
    await officerRef.update(updates);
    const updatedSnapshot = await officerRef.once('value');
    res.status(200).json(updatedSnapshot.val());
  } catch (error) {
    next(error);
  }
};

const deleteOfficer = async (req, res, next) => {
  try {
    const { officerId } = req.params;
    const officerRef = admin.database().ref(`officers/${officerId}`);
    const snapshot = await officerRef.once('value');

    if (!snapshot.exists()) {
      return res.status(404).json({ message: 'Officer not found.' });
    }

    await officerRef.remove();
    res.status(200).json({ message: 'Officer deleted successfully.' });
  } catch (error) {
    next(error);
  }
};

module.exports = {
  createOfficer,
  getOfficerById,
  getOfficersByPostOffice,
  getAllOfficers,
  updateOfficer,
  deleteOfficer,
};
