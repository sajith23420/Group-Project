const admin = require('../config/firebaseAdmin');
const PostOffice = require('../models/postOfficeModel');

const createPostOffice = async (req, res, next) => {
  try {
    const { name, postalCode, address, contactNumber, postmasterName, servicesOffered, operatingHours, latitude, longitude, subPostOfficeIds } = req.validatedBody;
    const postOfficesRef = admin.database().ref('postOffices');
    const newPostOfficeRef = postOfficesRef.push();
    const postOfficeId = newPostOfficeRef.key;

    const newPostOffice = new PostOffice(
      postOfficeId,
      name,
      postalCode,
      address,
      contactNumber,
      postmasterName,
      servicesOffered,
      operatingHours,
      latitude,
      longitude,
      subPostOfficeIds
    );

    await newPostOfficeRef.set(newPostOffice.toFirestore());
    res.status(201).json(newPostOffice);
  } catch (error) {
    next(error);
  }
};

const getPostOfficeById = async (req, res, next) => {
  try {
    const { postOfficeId } = req.params;
    const postOfficeRef = admin.database().ref(`postOffices/${postOfficeId}`);
    const snapshot = await postOfficeRef.once('value');

    if (!snapshot.exists()) {
      return res.status(404).json({ message: 'Post office not found.' });
    }
    res.status(200).json(snapshot.val());
  } catch (error) {
    next(error);
  }
};

const getAllPostOffices = async (req, res, next) => {
  try {
    const { limit = 10, offset = 0, name, postalCode, service } = req.query;
    let postOfficesQuery = admin.database().ref('postOffices');

    const snapshot = await postOfficesQuery.once('value');
    let postOffices = [];
    snapshot.forEach(childSnapshot => {
      postOffices.push({ id: childSnapshot.key, ...childSnapshot.val() });
    });

    if (name) {
      postOffices = postOffices.filter(po => po.name.toLowerCase().includes(name.toLowerCase()));
    }
    if (postalCode) {
      postOffices = postOffices.filter(po => po.postalCode === postalCode);
    }
    if (service) {
      postOffices = postOffices.filter(po => po.servicesOffered && po.servicesOffered.includes(service));
    }
    
    const paginatedPostOffices = postOffices.slice(parseInt(offset), parseInt(offset) + parseInt(limit));

    res.status(200).json({
      total: postOffices.length,
      limit: parseInt(limit),
      offset: parseInt(offset),
      data: paginatedPostOffices,
    });
  } catch (error) {
    next(error);
  }
};

const updatePostOffice = async (req, res, next) => {
  try {
    const { postOfficeId } = req.params;
    const updates = req.validatedBody;

    const postOfficeRef = admin.database().ref(`postOffices/${postOfficeId}`);
    const snapshot = await postOfficeRef.once('value');

    if (!snapshot.exists()) {
      return res.status(404).json({ message: 'Post office not found.' });
    }

    updates.updatedAt = new Date().toISOString();
    await postOfficeRef.update(updates);
    const updatedSnapshot = await postOfficeRef.once('value');
    res.status(200).json(updatedSnapshot.val());
  } catch (error) {
    next(error);
  }
};

const deletePostOffice = async (req, res, next) => {
  try {
    const { postOfficeId } = req.params;
    const postOfficeRef = admin.database().ref(`postOffices/${postOfficeId}`);
    const snapshot = await postOfficeRef.once('value');

    if (!snapshot.exists()) {
      return res.status(404).json({ message: 'Post office not found.' });
    }

    await postOfficeRef.remove();
    res.status(200).json({ message: 'Post office deleted successfully.' });
  } catch (error) {
    next(error);
  }
};

const searchPostOffices = async (req, res, next) => {
  await getAllPostOffices(req, res, next);
};

module.exports = {
  createPostOffice,
  getPostOfficeById,
  getAllPostOffices,
  updatePostOffice,
  deletePostOffice,
  searchPostOffices,
};
