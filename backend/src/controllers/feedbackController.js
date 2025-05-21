const admin = require('../config/firebaseAdmin');
const Feedback = require('../models/feedbackModel');
const { FEEDBACK_STATUS } = require('../config/constants');

const submitFeedback = async (req, res, next) => {
  try {
    const userId = req.user.uid;
    const { postOfficeId, subject, message, rating } = req.validatedBody;

    const feedbackRef = admin.database().ref('feedback');
    const newFeedbackRef = feedbackRef.push();
    const feedbackId = newFeedbackRef.key;

    const newFeedback = new Feedback(
      feedbackId,
      userId,
      subject,
      message,
      postOfficeId,
      rating
    );

    await newFeedbackRef.set(newFeedback.toFirestore());
    res.status(201).json(newFeedback);
  } catch (error) {
    next(error);
  }
};

const getUserFeedback = async (req, res, next) => {
  try {
    const userId = req.user.uid;
    const feedbackRef = admin.database().ref('feedback');
    const snapshot = await feedbackRef.orderByChild('userId').equalTo(userId).once('value');
    
    const feedbackList = [];
    snapshot.forEach(childSnapshot => {
      feedbackList.push({ id: childSnapshot.key, ...childSnapshot.val() });
    });
    res.status(200).json(feedbackList);
  } catch (error) {
    next(error);
  }
};

const adminGetAllFeedback = async (req, res, next) => {
  try {
    const { status, postOfficeId, limit = 20, offset = 0 } = req.query;
    let feedbackQuery = admin.database().ref('feedback');

    const snapshot = await feedbackQuery.once('value');
    let feedbackList = [];
    snapshot.forEach(childSnapshot => {
        feedbackList.push({ id: childSnapshot.key, ...childSnapshot.val() });
    });

    if (status) {
        feedbackList = feedbackList.filter(f => f.status === status);
    }
    if (postOfficeId) {
        feedbackList = feedbackList.filter(f => f.postOfficeId === postOfficeId);
    }
    
    const paginatedFeedback = feedbackList.slice(parseInt(offset), parseInt(offset) + parseInt(limit));

    res.status(200).json({
        total: feedbackList.length,
        limit: parseInt(limit),
        offset: parseInt(offset),
        data: paginatedFeedback
    });
  } catch (error) {
    next(error);
  }
};

const adminUpdateFeedbackStatus = async (req, res, next) => {
  try {
    const { feedbackId } = req.params;
    const { status, adminResponse } = req.validatedBody;

    const feedbackRef = admin.database().ref(`feedback/${feedbackId}`);
    const snapshot = await feedbackRef.once('value');

    if (!snapshot.exists()) {
      return res.status(404).json({ message: 'Feedback not found.' });
    }

    const updates = {
      status,
      updatedAt: new Date().toISOString(),
    };
    if (adminResponse !== undefined) {
      updates.adminResponse = adminResponse;
    }

    await feedbackRef.update(updates);
    const updatedSnapshot = await feedbackRef.once('value');
    res.status(200).json(updatedSnapshot.val());
  } catch (error) {
    next(error);
  }
};

module.exports = {
  submitFeedback,
  getUserFeedback,
  adminGetAllFeedback,
  adminUpdateFeedbackStatus,
};
